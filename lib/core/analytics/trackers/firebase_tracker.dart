import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../models/analytics_event.dart';
import '../models/user_properties.dart';
import 'analytics_tracker.dart';

/// Firebase Analytics tracker implementation.
///
/// Translates typed [AnalyticsEvent]s into Firebase Analytics calls.
/// Firebase has restrictions on property names and values (40 chars keys,
/// 100 chars values for user properties, 25 params per event) — this tracker
/// handles those constraints gracefully.
///
/// Errors are caught and reported as Sentry messages (not crashes) per
/// `.agents/analytics-growth.md` guidelines.
class FirebaseTracker implements AnalyticsTracker {
  FirebaseTracker({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;
  bool _enabled = false;

  @override
  String get trackerName => 'Firebase';

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
    // Firebase uses setAnalyticsCollectionEnabled for consent
    _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> track(AnalyticsEvent event) async {
    if (!_enabled) return;

    try {
      await _analytics.logEvent(
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

    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      _reportError('setUserId', e);
    }
  }

  @override
  Future<void> setUserProperties(UserProperties properties) async {
    if (!_enabled) return;

    try {
      final map = properties.toMap();
      for (final entry in map.entries) {
        // Firebase user property names max 40 chars, values max 100 chars
        final key = entry.key.length > 40 ? entry.key.substring(0, 40) : entry.key;
        final value = _truncateValue(entry.value);
        await _analytics.setUserProperty(name: key, value: value);
      }
    } catch (e) {
      _reportError('setUserProperties', e);
    }
  }

  @override
  Future<void> reset() async {
    try {
      await _analytics.setUserId(id: null);
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
      final key = entry.key.length > 40 ? entry.key.substring(0, 40) : entry.key;
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
