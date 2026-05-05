import '../models/analytics_event.dart';
import '../models/user_properties.dart';

/// Common interface that every analytics tracker must implement.
///
/// This is the Strategy in the Strategy pattern — `AnalyticsService` holds
/// a list of `AnalyticsTracker` instances and delegates to all of them.
///
/// Each tracker wraps a specific third-party SDK (Firebase, Mixpanel, etc.)
/// and translates the typed event/properties into the SDK's own API.
///
/// Implementations MUST be non-blocking: all methods should return immediately
/// and perform their work asynchronously. Errors must be caught internally
/// and never propagate to the caller.
abstract class AnalyticsTracker {
  /// Human-readable name for logging and debugging.
  String get trackerName;

  /// Track a typed analytics event.
  Future<void> track(AnalyticsEvent event);

  /// Set the user identity for this tracker.
  Future<void> setUserId(String userId);

  /// Set user properties for segmentation.
  Future<void> setUserProperties(UserProperties properties);

  /// Reset the user identity (typically on logout).
  Future<void> reset();

  /// Enable or disable this tracker based on user consent.
  void setEnabled(bool enabled);
}
