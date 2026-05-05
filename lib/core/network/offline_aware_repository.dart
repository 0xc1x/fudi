import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../error/data_exceptions.dart';
import '../error/network_exceptions.dart';

/// Result wrapper for offline-aware operations.
///
/// Carries the data and metadata about whether it came from cache
/// and whether the data might be stale.
class OfflineResult<T> {
  final T data;
  final bool fromCache;
  final bool isStale;
  final DateTime? cachedAt;

  const OfflineResult({
    required this.data,
    this.fromCache = false,
    this.isStale = false,
    this.cachedAt,
  });

  /// Fresh data from the network.
  factory OfflineResult.fresh(T data) => OfflineResult(data: data);

  /// Data from cache, possibly stale.
  factory OfflineResult.cached(T data, {bool isStale = false, DateTime? cachedAt}) =>
      OfflineResult(data: data, fromCache: true, isStale: isStale, cachedAt: cachedAt);
}

/// Stale-while-revalidate repository pattern.
///
/// Strategy from docs/ai/ERROR_HANDLING.md:
/// - If online: fetch from network, update cache, return fresh data.
/// - If offline: return cached data (even if stale).
/// - If network fails but cache exists: return cached data with fromCache=true.
/// - If no cache and no network: throw [ConnectionException].
///
/// Cache is stored in [FlutterSecureStorage] as JSON with metadata
/// (timestamp, staleness). This is a simple key-value cache suitable
/// for Phase 1. For Phase 2+, consider Hive or Isar for structured data.
///
/// Usage:
/// ```dart
/// final result = await offlineRepo.execute(
///   remote: () => apiClient.get('/offers'),
///   cacheKey: 'offers:nearby',
///   maxStaleness: Duration(minutes: 5),
/// );
/// if (result.fromCache) { showOfflineBanner(); }
/// ```
class OfflineAwareRepository {
  final InternetConnection _connectivity;
  final FlutterSecureStorage _secureStorage;

  OfflineAwareRepository({
    required InternetConnection connectivity,
    FlutterSecureStorage? secureStorage,
  })  : _connectivity = connectivity,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Executes an operation with offline-aware caching.
  ///
  /// [remote] — The network operation to execute when online.
  /// [cacheKey] — Unique key for caching the result.
  /// [maxStaleness] — How long cached data is considered fresh.
  /// [serializer] — Converts the result to JSON for caching.
  /// [deserializer] — Converts cached JSON back to the result type.
  ///
  /// Flow:
  /// 1. Check connectivity
  /// 2. If online → try remote → cache result → return fresh
  /// 3. If online but remote fails → try cache → return cached (stale ok)
  /// 4. If offline → try cache → return cached (may be stale)
  /// 5. If no cache and offline → throw ConnectionException
  Future<OfflineResult<T>> execute<T>({
    required Future<T> Function() remote,
    required String cacheKey,
    required Map<String, dynamic> Function(T) serializer,
    required T Function(Map<String, dynamic>) deserializer,
    Duration maxStaleness = const Duration(minutes: 5),
  }) async {
    final isOnline = await _connectivity.hasInternetAccess;

    if (isOnline) {
      try {
        final result = await remote();
        await _saveToCache(cacheKey, result, serializer);
        return OfflineResult.fresh(result);
      } on NetworkException {
        // Network failed — fall back to cache
        return await _readFromCache(cacheKey, deserializer, maxStaleness);
      }
    }

    // Offline — read from cache
    return await _readFromCache(cacheKey, deserializer, maxStaleness);
  }

  /// Stale-while-revalidate: return cached data immediately,
  /// then silently refresh from network in the background.
  ///
  /// Use this for lists (offers, orders) where showing slightly
  /// stale data is acceptable and fresh data can arrive shortly after.
  ///
  /// Returns the cached data immediately (if available) or waits
  /// for the network result. The [onRefreshed] callback fires when
  /// the background refresh completes with new data.
  Future<OfflineResult<T>> executeStaleWhileRevalidate<T>({
    required Future<T> Function() remote,
    required String cacheKey,
    required Map<String, dynamic> Function(T) serializer,
    required T Function(Map<String, dynamic>) deserializer,
    required void Function(T freshData) onRefreshed,
    Duration maxStaleness = const Duration(minutes: 5),
  }) async {
    final isOnline = await _connectivity.hasInternetAccess;

    // Try cache first — return immediately if available
    final cached = await _tryReadFromCache(cacheKey, deserializer, maxStaleness);
    if (cached != null) {
      // Kick off background refresh if online
      if (isOnline) {
        _refreshInBackground(cacheKey, remote, serializer, onRefreshed);
      }
      return cached;
    }

    // No cache — must wait for network
    if (isOnline) {
      try {
        final result = await remote();
        await _saveToCache(cacheKey, result, serializer);
        return OfflineResult.fresh(result);
      } on NetworkException {
        rethrow;
      }
    }

    // No cache and offline — nothing we can do
    throw const ConnectionException();
  }

  /// Invalidates the cache entry for the given key.
  Future<void> invalidateCache(String cacheKey) async {
    await _secureStorage.delete(key: _storageKey(cacheKey));
  }

  /// Clears all cache entries managed by this repository.
  Future<void> clearAllCache() async {
    // FlutterSecureStorage doesn't support prefix-based deletion,
    // so we read all keys and filter by our prefix.
    final allKeys = await _secureStorage.readAll();
    final cacheKeys = allKeys.keys.where((k) => k.startsWith('fudi_cache_'));
    for (final key in cacheKeys) {
      await _secureStorage.delete(key: key);
    }
  }

  // ─── Private helpers ────────────────────────────────────────────

  Future<void> _saveToCache<T>(
    String cacheKey,
    T data,
    Map<String, dynamic> Function(T) serializer,
  ) async {
    try {
      final entry = _CacheEntry(
        data: serializer(data),
        cachedAt: DateTime.now(),
      );
      await _secureStorage.write(
        key: _storageKey(cacheKey),
        value: jsonEncode(entry.toJson()),
      );
    } on Exception {
      // Cache write failure is non-fatal — don't crash the app
    }
  }

  Future<OfflineResult<T>> _readFromCache<T>(
    String cacheKey,
    T Function(Map<String, dynamic>) deserializer,
    Duration maxStaleness,
  ) async {
    final cached = await _tryReadFromCache(cacheKey, deserializer, maxStaleness);
    if (cached != null) return cached;
    throw const CacheException(message: 'No hay datos en caché');
  }

  Future<OfflineResult<T>?> _tryReadFromCache<T>(
    String cacheKey,
    T Function(Map<String, dynamic>) deserializer,
    Duration maxStaleness,
  ) async {
    try {
      final raw = await _secureStorage.read(key: _storageKey(cacheKey));
      if (raw == null) return null;

      final entry = _CacheEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      final data = deserializer(entry.data);
      final age = DateTime.now().difference(entry.cachedAt);
      final isStale = age > maxStaleness;

      return OfflineResult.cached(data, isStale: isStale, cachedAt: entry.cachedAt);
    } on Exception {
      return null;
    }
  }

  void _refreshInBackground<T>(
    String cacheKey,
    Future<T> Function() remote,
    Map<String, dynamic> Function(T) serializer,
    void Function(T) onRefreshed,
  ) {
    // Fire and forget — errors are silently swallowed
    remote().then((freshData) async {
      await _saveToCache(cacheKey, freshData, serializer);
      onRefreshed(freshData);
    }).catchError((_) {
      // Background refresh failure is non-fatal
    });
  }

  String _storageKey(String cacheKey) => 'fudi_cache_$cacheKey';
}

/// Internal cache entry with metadata.
class _CacheEntry {
  final Map<String, dynamic> data;
  final DateTime cachedAt;

  _CacheEntry({required this.data, required this.cachedAt});

  Map<String, dynamic> toJson() => {
    'data': data,
    'cached_at': cachedAt.toIso8601String(),
  };

  factory _CacheEntry.fromJson(Map<String, dynamic> json) => _CacheEntry(
    data: json['data'] as Map<String, dynamic>,
    cachedAt: DateTime.parse(json['cached_at'] as String),
  );
}

/// Riverpod provider for [OfflineAwareRepository].
///
/// Depends on [InternetConnection] for connectivity checks.
final offlineAwareRepositoryProvider = Provider<OfflineAwareRepository>((ref) {
  return OfflineAwareRepository(
    connectivity: InternetConnection(),
  );
});
