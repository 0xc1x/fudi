import 'package:supabase_flutter/supabase_flutter.dart';

/// A [LocalStorage] wrapper that delegates all operations to the underlying
/// storage without prematurely clearing expired sessions.
///
/// Session staleness is handled by [AuthSessionNotifier] which attempts
/// a silent refresh on cold start before declaring the user signed out.
class ValidatingLocalStorage extends LocalStorage {
  final LocalStorage _delegate;

  const ValidatingLocalStorage({required LocalStorage delegate})
    : _delegate = delegate;

  @override
  Future<void> initialize() => _delegate.initialize();

  @override
  Future<bool> hasAccessToken() => _delegate.hasAccessToken();

  @override
  Future<String?> accessToken() => _delegate.accessToken();

  @override
  Future<void> removePersistedSession() =>
      _delegate.removePersistedSession();

  @override
  Future<void> persistSession(String persistSessionString) =>
      _delegate.persistSession(persistSessionString);
}
