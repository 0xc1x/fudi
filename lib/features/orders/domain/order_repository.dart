import 'order_model.dart';
import 'reservation_result.dart';

abstract class OrderRepository {
  Future<ReservationResult> reserveOffer({
    required String offerId,
    String? couponId,
  });

  Future<List<OrderModel>> getUserOrders();

  Future<OrderModel> getOrderById(String id);

  Future<CancelOrderResult> cancelOrder(String orderId);

  Stream<OrderModel> watchOrder(String id);

  Stream<List<OrderModel>> watchUserOrders();
}

class CancelOrderResult {
  const CancelOrderResult({
    required this.success,
    this.orderId,
    this.errorCode,
    this.message,
  });

  final bool success;
  final String? orderId;
  final String? errorCode;
  final String? message;
}
