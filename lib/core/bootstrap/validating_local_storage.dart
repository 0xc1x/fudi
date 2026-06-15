import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A [LocalStorage] wrapper that validates session expiration before
/// returning the persisted session to Supabase Auth.
///
/// This prevents the GoTrue JS client from entering an infinite refresh loop
/// when the stored session has an expired refresh token (which causes 429
/// rate limit errors and continuous retries).
class ValidatingLocalStorage extends LocalStorage {
  final LocalStorage _delegate;

  const ValidatingLocalStorage({required LocalStorage delegate})
    : _delegate = delegate;

  @override
  Future<void> initialize() async {
    await _delegate.initialize();
    if (kIsWeb) {
      await _clearExpiredSessionIfNeeded();
    }
  }

  @override
  Future<bool> hasAccessToken() async {
    if (kIsWeb) {
      await _clearExpiredSessionIfNeeded();
    }
    return _delegate.hasAccessToken();
  }

  @override
  Future<String?> accessToken() async {
    if (kIsWeb) {
      await _clearExpiredSessionIfNeeded();
    }
    return _delegate.accessToken();
  }

  @override
  Future<void> removePersistedSession() async {
    await _delegate.removePersistedSession();
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _delegate.persistSession(persistSessionString);
  }

  Future<void> _clearExpiredSessionIfNeeded() async {
    try {
      final sessionString = await _delegate.accessToken();
      if (sessionString == null) return;

      final sessionJson = jsonDecode(sessionString) as Map<String, dynamic>;
      final expiresAt = sessionJson['expires_at'] as int?;

      if (expiresAt != null) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (now >= expiresAt) {
          await _delegate.removePersistedSession();
        }
      }
    } catch (_) {
      // If parsing fails, remove the corrupted session
      await _delegate.removePersistedSession();
    }
  }
}
