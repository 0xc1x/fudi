import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../models/analytics_event.dart';
import '../models/user_properties.dart';
import 'analytics_tracker.dart';

class FirebaseTracker implements AnalyticsTracker {
  FirebaseTracker({FirebaseAnalytics? analytics})
    : _analytics = analytics,
      _initialized = analytics != null;

  FirebaseAnalytics? _analytics;
  bool _initialized;
  bool _enabled = false;
  bool _initAttempted = false;

  @override
  String get trackerName => 'Firebase';

  Future<void> _ensureInitialized() async {
    if (_initialized || _initAttempted) return;
    _initAttempted = true;

    try {
      if (Firebase.apps.isEmpty) return;
      _analytics = FirebaseAnalytics.instance;
      _initialized = true;
    } catch (e) {
      _reportError('init', e);
    }
  }

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
    final analytics = _analytics;
    if (analytics == null) return;
    try {
      analytics.setAnalyticsCollectionEnabled(enabled);
    } catch (e) {
      _reportError('setEnabled', e);
    }
  }

  @override
  Future<void> track(AnalyticsEvent event) async {
    if (!_enabled) return;
    await _ensureInitialized();
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.logEvent(
        name: event.name,
        parameters: _sanitizeProperties(event.properties),
      );
    } catch (e) {
      _reportError('track', e);
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    if (!_enabled) return;
    await _ensureInitialized();
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.setUserId(id: userId);
    } catch (e) {
      _reportError('setUserId', e);
    }
  }

  @override
  Future<void> setUserProperties(UserProperties properties) async {
    if (!_enabled) return;
    await _ensureInitialized();
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      final map = properties.toMap();
      for (final entry in map.entries) {
        final key = entry.key.length > 40
            ? entry.key.substring(0, 40)
            : entry.key;
        final value = _truncateValue(entry.value);
        await analytics.setUserProperty(name: key, value: value);
      }
    } catch (e) {
      _reportError('setUserProperties', e);
    }
  }

  @override
  Future<void> reset() async {
    await _ensureInitialized();
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.setUserId(id: null);
    } catch (e) {
      _reportError('reset', e);
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  /// Sanitizes event properties for Firebase constraints.
  ///
  /// Firebase allows max 25 parameters per event. Keys max 40 chars.
  /// Values must be primitive types (String, int, double, bool).
  Map<String, Object> _sanitizeProperties(Map<String, dynamic> properties) {
    final sanitized = <String, Object>{};
    final entries = properties.entries.take(25);

    for (final entry in entries) {
      final key = entry.key.length > 40
          ? entry.key.substring(0, 40)
          : entry.key;
      final value = entry.value;
      if (value is String || value is int || value is double || value is bool) {
        sanitized[key] = value;
      } else {
        // Fallback: stringify non-primitive values
        sanitized[key] = value.toString();
      }
    }

    return sanitized;
  }

  /// Truncates a value to Firebase's 100-char limit for user properties.
  String? _truncateValue(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return str.length > 100 ? str.substring(0, 100) : str;
  }

  /// Reports analytics errors as Sentry messages (NOT crashes).
  ///
  /// Per `.agents/analytics-growth.md`: "No enviar errores de analytics
  /// a Sentry como crashes — solo como messages."
  void _reportError(String method, Object error) {
    Sentry.captureMessage(
      'FirebaseTracker.$method failed: $error',
      level: SentryLevel.warning,
    );
  }
}
