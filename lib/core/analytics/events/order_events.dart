import '../models/analytics_event.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Order Events — docs/ai/ANALYTICS.md → Orders (Conversion)
// ─────────────────────────────────────────────────────────────────────────────

/// The user started the reserve flow for an offer.
class OrderReserveStartedEvent extends AnalyticsEvent {
  final String offerId;
  final String businessId;
  final double amount;

  OrderReserveStartedEvent({
    required this.offerId,
    required this.businessId,
    required this.amount,
  });

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
  final String orderId;
  final double amount;
  final String paymentMethod;

  OrderPaymentInitiatedEvent({
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
  });

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
  final String orderId;
  final double amount;
  final String gateway;

  OrderPaymentCompletedEvent({
    required this.orderId,
    required this.amount,
    required this.gateway,
  });

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
  final String orderId;
  final String errorType;

  OrderPaymentFailedEvent({required this.orderId, required this.errorType});

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
  final String orderId;
  final String businessId;

  OrderPickupConfirmedEvent({required this.orderId, required this.businessId});

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
  final String orderId;
  final String reason;

  /// Who cancelled: user, business, or system.
  final String by;

  OrderCancelledEvent({
    required this.orderId,
    required this.reason,
    required this.by,
  });

  @override
  String get name => 'order_cancelled';

  @override
  Map<String, dynamic> get properties => {
    'order_id': orderId,
    'reason': reason,
    'by': by,
  };
}
