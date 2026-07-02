import '../models/analytics_event.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Order Events — docs/ai/ANALYTICS.md → Orders (Conversion)
// ─────────────────────────────────────────────────────────────────────────────

/// The user started the reserve flow for an offer.
class OrderReserveStartedEvent extends AnalyticsEvent {
  OrderReserveStartedEvent({
    required this.offerId,
    required this.businessId,
    required this.amount,
  });
  final String offerId;
  final String businessId;
  final double amount;

  @override
  String get name => 'order_reserve_started';

  @override
  Map<String, dynamic> get properties => {
    'offer_id': offerId,
    'business_id': businessId,
    'amount': amount,
  };
}

/// The user initiated payment for an order.
class OrderPaymentInitiatedEvent extends AnalyticsEvent {
  OrderPaymentInitiatedEvent({
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
  });
  final String orderId;
  final double amount;
  final String paymentMethod;

  @override
  String get name => 'order_payment_initiated';

  @override
  Map<String, dynamic> get properties => {
    'order_id': orderId,
    'amount': amount,
    'payment_method': paymentMethod,
  };
}

/// Payment completed successfully.
class OrderPaymentCompletedEvent extends AnalyticsEvent {
  OrderPaymentCompletedEvent({
    required this.orderId,
    required this.amount,
    required this.gateway,
  });
  final String orderId;
  final double amount;
  final String gateway;

  @override
  String get name => 'order_payment_completed';

  @override
  Map<String, dynamic> get properties => {
    'order_id': orderId,
    'amount': amount,
    'gateway': gateway,
  };
}

/// Payment failed.
class OrderPaymentFailedEvent extends AnalyticsEvent {
  OrderPaymentFailedEvent({required this.orderId, required this.errorType});
  final String orderId;
  final String errorType;

  @override
  String get name => 'order_payment_failed';

  @override
  Map<String, dynamic> get properties => {
    'order_id': orderId,
    'error_type': errorType,
  };
}

/// Pickup was confirmed by the business or the user.
class OrderPickupConfirmedEvent extends AnalyticsEvent {
  OrderPickupConfirmedEvent({required this.orderId, required this.businessId});
  final String orderId;
  final String businessId;

  @override
  String get name => 'order_pickup_confirmed';

  @override
  Map<String, dynamic> get properties => {
    'order_id': orderId,
    'business_id': businessId,
  };
}

/// Order was cancelled.
class OrderCancelledEvent extends AnalyticsEvent {
  OrderCancelledEvent({
    required this.orderId,
    required this.reason,
    required this.by,
  });
  final String orderId;
  final String reason;

  /// Who cancelled: user, business, or system.
  final String by;

  @override
  String get name => 'order_cancelled';

  @override
  Map<String, dynamic> get properties => {
    'order_id': orderId,
    'reason': reason,
    'by': by,
  };
}
