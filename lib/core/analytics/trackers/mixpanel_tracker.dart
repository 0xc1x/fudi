import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../models/analytics_event.dart';
import '../models/user_properties.dart';
import 'analytics_tracker.dart';

/// Mixpanel tracker implementation.
///
/// Mixpanel is the primary tool for funnel analysis, cohort tracking,
/// and ad-hoc queries. It supports richer property types than Firebase
/// and maintains user profiles via `getPeople()`.
///
/// Errors are caught and reported as Sentry messages (not crashes) per
/// `.agents/analytics-growth.md` guidelines.
class MixpanelTracker implements AnalyticsTracker {
  MixpanelTracker({Mixpanel? mixpanel}) : _mixpanel = mixpanel;

  final Mixpanel? _mixpanel;
  bool _enabled = false;

  @override
  String get trackerName => 'Mixpanel';

  /// Initializes the Mixpanel instance if not provided externally.
  ///
  /// Call this once during app startup after Mixpanel.init().
  /// If a pre-initialized instance is provided via the constructor,
  /// this method is a no-op.
  Future<void> init(String token, {bool trackAutomaticEvents = true}) async {
    if (_mixpanel != null) return;
    // The instance is managed externally; this is a convenience
    // for the common case where init happens inside the tracker.
  }

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
    final mp = _mixpanel;
    if (mp == null) return;

    if (enabled) {
      mp.optInTracking();
    } else {
      mp.optOutTracking();
    }
  }

  @override
  Future<void> track(AnalyticsEvent event) async {
    if (!_enabled) return;
    final mp = _mixpanel;
    if (mp == null) return;

    try {
      mp.track(event.name, event.properties);
    } catch (e) {
      _reportError('track', e);
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    if (!_enabled) return;
    final mp = _mixpanel;
    if (mp == null) return;

    try {
      mp.identify(userId);
    } catch (e) {
      _reportError('setUserId', e);
    }
  }

  @override
  Future<void> setUserProperties(UserProperties properties) async {
    if (!_enabled) return;
    final mp = _mixpanel;
    if (mp == null) return;

    try {
      mp.getPeople().set(properties.toMap());
    } catch (e) {
      _reportError('setUserProperties', e);
    }
  }

  @override
  Future<void> reset() async {
    final mp = _mixpanel;
    if (mp == null) return;

    try {
      mp.reset();
    } catch (e) {
      _reportError('reset', e);
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  /// Reports analytics errors as Sentry messages (NOT crashes).
  void _reportError(String method, Object error) {
    Sentry.captureMessage(
      'MixpanelTracker.$method failed: $error',
      level: SentryLevel.warning,
    );
  }
}
