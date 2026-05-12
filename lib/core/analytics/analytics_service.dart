import 'package:sentry_flutter/sentry_flutter.dart';

import 'events/navigation_events.dart';
import 'models/analytics_event.dart';
import 'models/user_properties.dart';
import 'trackers/analytics_tracker.dart';

/// Central analytics service that delegates to multiple trackers.
///
/// This is the **only** class that feature code should import for analytics.
/// It holds a list of [AnalyticsTracker] instances (Firebase, Mixpanel, etc.)
/// and fans out every call to all of them.
///
/// Design principles:
/// - **Fire-and-forget**: All methods return immediately. Errors are caught
///   internally and reported as Sentry messages (NOT crashes).
/// - **Consent-aware**: Trackers are only enabled after the user grants
///   analytics consent. Until then, all calls are no-ops.
/// - **Non-blocking**: No analytics call should ever block the UI thread
///   or cause a visible delay.
///
/// Usage:
/// ```dart
/// final analytics = ref.read(analyticsServiceProvider);
/// await analytics.track(AuthLoginStartedEvent(method: AuthMethod.email));
/// await analytics.setUserId('user-123');
/// ```
class AnalyticsService {
  final List<AnalyticsTracker> _trackers;
  bool _consentGranted = false;

  AnalyticsService({required List<AnalyticsTracker> trackers})
    : _trackers = trackers;

  /// Whether the user has granted analytics consent.
  bool get consentGranted => _consentGranted;

  /// Updates consent status and enables/disables all trackers.
  ///
  /// Call this after the user accepts or rejects analytics consent.
  /// Until consent is granted, all tracking calls are silently ignored.
  void setConsent(bool granted) {
    _consentGranted = granted;
    for (final tracker in _trackers) {
      tracker.setEnabled(granted);
    }
  }

  /// Tracks a typed analytics event across all trackers.
  ///
  /// If consent has not been granted, this is a no-op.
  /// Errors in individual trackers are caught and reported as
  /// Sentry messages — they never propagate to the caller.
  Future<void> track(AnalyticsEvent event) async {
    if (!_consentGranted) return;

    for (final tracker in _trackers) {
      try {
        await tracker.track(event);
      } catch (e) {
        _reportTrackerError(tracker.trackerName, 'track', e);
      }
    }
  }

  /// Sets the user identity across all trackers.
  ///
  /// Call this after successful login/signup.
  /// If consent has not been granted, this is a no-op.
  Future<void> setUserId(String userId) async {
    if (!_consentGranted) return;

    for (final tracker in _trackers) {
      try {
        await tracker.setUserId(userId);
      } catch (e) {
        _reportTrackerError(tracker.trackerName, 'setUserId', e);
      }
    }
  }

  /// Sets user properties for segmentation across all trackers.
  ///
  /// Call this when user profile data changes (role, city, preferences).
  /// If consent has not been granted, this is a no-op.
  Future<void> setUserProperties(UserProperties properties) async {
    if (!_consentGranted) return;

    for (final tracker in _trackers) {
      try {
        await tracker.setUserProperties(properties);
      } catch (e) {
        _reportTrackerError(tracker.trackerName, 'setUserProperties', e);
      }
    }
  }

  /// Resets the user identity across all trackers.
  ///
  /// Call this on logout to prevent cross-user data contamination.
  /// This always runs regardless of consent — it's a privacy operation.
  Future<void> reset() async {
    for (final tracker in _trackers) {
      try {
        await tracker.reset();
      } catch (e) {
        _reportTrackerError(tracker.trackerName, 'reset', e);
      }
    }
  }

  // ─── Convenience methods for common events ──────────────────────

  /// Tracks a screen view event.
  Future<void> trackScreenView({
    required String screenName,
    String? source,
    String? role,
  }) {
    return track(
      ScreenViewedEvent(screenName: screenName, source: source, role: role),
    );
  }

  /// Tracks a bottom nav tap event.
  Future<void> trackBottomNavTap({
    required int tabIndex,
    required String tabName,
  }) {
    return track(BottomNavTappedEvent(tabIndex: tabIndex, tabName: tabName));
  }

  // ─── Private helpers ────────────────────────────────────────────

  /// Reports tracker errors as Sentry messages (NOT crashes).
  ///
  /// Per analytics-growth guidelines: analytics errors should never
  /// crash the app or appear to the user. They're operational signals
  /// for the engineering team.
  void _reportTrackerError(String trackerName, String method, Object error) {
    Sentry.captureMessage(
      'AnalyticsService: $trackerName.$method failed: $error',
      level: SentryLevel.warning,
    );
  }
}
