import 'package:meta/meta.dart';

/// Base sealed class for all analytics events in Fudi.
///
/// Every event that flows through the analytics pipeline must extend this
/// class. This guarantees type safety — no raw strings — and ensures every
/// event carries a well-defined name and properties map.
///
/// Usage:
/// ```dart
/// class OfferDetailViewedEvent extends AnalyticsEvent {
///   OfferDetailViewedEvent({required this.offerId, required this.businessId});
///
///   final String offerId;
///   final String businessId;
///
///   @override
///   String get name => 'offer_detail_viewed';
///
///   @override
///   Map<String, dynamic> get properties => {'offer_id': offerId, 'business_id': businessId};
/// }
/// ```
@immutable
abstract class AnalyticsEvent {
  /// The stable event name used across all trackers.
  ///
  /// Convention: `feature_action` in snake_case (e.g. `auth_login_completed`).
  String get name;

  /// Structured properties attached to this event.
  ///
  /// Keys must be snake_case. Values must be JSON-serializable primitives
  /// (String, int, double, bool, List, Map). Never include PII.
  Map<String, dynamic> get properties;

  /// Timestamp of when this event was created.
  ///
  /// Defaults to the moment the object is instantiated.
  final DateTime timestamp;

  AnalyticsEvent() : timestamp = DateTime.now();
}
