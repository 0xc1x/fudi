import '../../../core/network/payment_gateway.dart';

class MockPaymentGateway implements PaymentGateway {
  @override
  String get name => 'mock';

  @override
  Future<PaymentResult> process({
    required String orderId,
    required double amount,
    required String currency,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return PaymentSuccess(
      gatewayId: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      gateway: name,
    );
  }

  @override
  Future<void> refund({
    required String paymentIntentId,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
