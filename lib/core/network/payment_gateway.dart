sealed class PaymentResult {
  const PaymentResult();
}

class PaymentSuccess extends PaymentResult {
  const PaymentSuccess({
    required this.gatewayId,
    required this.gateway,
  });

  final String gatewayId;
  final String gateway;
}

class PaymentFailure extends PaymentResult {
  const PaymentFailure({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

abstract class PaymentGateway {
  String get name;

  Future<PaymentResult> process({
    required String orderId,
    required double amount,
    required String currency,
  });

  Future<void> refund({
    required String paymentIntentId,
    required double amount,
  });
}
