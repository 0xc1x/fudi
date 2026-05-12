import '../models/analytics_event.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Payment Events — docs/ai/ANALYTICS.md → Orders (Conversion) + Payments
// ─────────────────────────────────────────────────────────────────────────────

/// The user entered the checkout flow.
class CheckoutStartedEvent extends AnalyticsEvent {
  final String offerId;
  final String businessId;
  final double amount;

  CheckoutStartedEvent({
    required this.offerId,
    required this.businessId,
    required this.amount,
  });

  @override
  String get name => 'checkout_started';

  @override
  Map<String, dynamic> get properties => {
    'offer_id': offerId,
    'business_id': businessId,
    'amount': amount,
  };
}

/// Payment completed successfully (alias-level event for the payment funnel).
class PaymentCompletedEvent extends AnalyticsEvent {
  final String orderId;
  final double amount;
  final String gateway;
  final String paymentMethod;

  PaymentCompletedEvent({
    required this.orderId,
    required this.amount,
    required this.gateway,
    required this.paymentMethod,
  });

  @override
  String get name => 'payment_completed';

  @override
  Map<String, dynamic> get properties => {
    'order_id': orderId,
    'amount': amount,
    'gateway': gateway,
    'payment_method': paymentMethod,
  };
}

/// Payment failed at the gateway level.
class PaymentFailedEvent extends AnalyticsEvent {
  final String orderId;
  final String errorType;
  final String gateway;

  PaymentFailedEvent({
    required this.orderId,
    required this.errorType,
    required this.gateway,
  });

  @override
  String get name => 'payment_failed';

  @override
  Map<String, dynamic> get properties => {
    'order_id': orderId,
    'error_type': errorType,
    'gateway': gateway,
  };
}

/// User requested a refund.
class RefundRequestedEvent extends AnalyticsEvent {
  final String orderId;
  final String reason;

  RefundRequestedEvent({required this.orderId, required this.reason});

  @override
  String get name => 'refund_requested';

  @override
  Map<String, dynamic> get properties => {
    'order_id': orderId,
    'reason': reason,
  };
}
