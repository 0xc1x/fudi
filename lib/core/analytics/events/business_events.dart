import '../models/analytics_event.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Business Events — docs/ai/ANALYTICS.md → Business (Operación)
// ─────────────────────────────────────────────────────────────────────────────

/// A business created a new offer.
class BusinessOfferCreatedEvent extends AnalyticsEvent {
  final String businessId;
  final String offerId;
  final double price;

  BusinessOfferCreatedEvent({
    required this.businessId,
    required this.offerId,
    required this.price,
  });

  @override
  String get name => 'business_offer_created';

  @override
  Map<String, dynamic> get properties => {
    'business_id': businessId,
    'offer_id': offerId,
    'price': price,
  };
}

/// A business updated an existing offer.
class BusinessOfferUpdatedEvent extends AnalyticsEvent {
  final String businessId;
  final String offerId;

  /// What changed: price, stock, description, etc.
  final String changeType;

  BusinessOfferUpdatedEvent({
    required this.businessId,
    required this.offerId,
    required this.changeType,
  });

  @override
  String get name => 'business_offer_updated';

  @override
  Map<String, dynamic> get properties => {
    'business_id': businessId,
    'offer_id': offerId,
    'change_type': changeType,
  };
}

/// A business disabled an offer.
class BusinessOfferDisabledEvent extends AnalyticsEvent {
  final String businessId;
  final String offerId;
  final String reason;

  BusinessOfferDisabledEvent({
    required this.businessId,
    required this.offerId,
    required this.reason,
  });

  @override
  String get name => 'business_offer_disabled';

  @override
  Map<String, dynamic> get properties => {
    'business_id': businessId,
    'offer_id': offerId,
    'reason': reason,
  };
}

/// A business performed an action on an order (confirm, reject, etc.).
class BusinessOrderManagedEvent extends AnalyticsEvent {
  final String businessId;
  final String orderId;

  /// The action taken: confirmed, rejected, prepared, etc.
  final String action;

  BusinessOrderManagedEvent({
    required this.businessId,
    required this.orderId,
    required this.action,
  });

  @override
  String get name => 'business_order_managed';

  @override
  Map<String, dynamic> get properties => {
    'business_id': businessId,
    'order_id': orderId,
    'action': action,
  };
}

/// A business viewed their dashboard.
class BusinessDashboardViewedEvent extends AnalyticsEvent {
  final String businessId;

  BusinessDashboardViewedEvent({required this.businessId});

  @override
  String get name => 'business_dashboard_viewed';

  @override
  Map<String, dynamic> get properties => {'business_id': businessId};
}

/// A business requested a payout.
class BusinessPayoutRequestedEvent extends AnalyticsEvent {
  final String businessId;
  final double amount;

  BusinessPayoutRequestedEvent({
    required this.businessId,
    required this.amount,
  });

  @override
  String get name => 'business_payout_requested';

  @override
  Map<String, dynamic> get properties => {
    'business_id': businessId,
    'amount': amount,
  };
}
