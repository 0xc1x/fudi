import '../../orders/domain/order_model.dart';
import '../../orders/domain/order_status.dart';

/// Repository for business-side order management.
abstract class BusinessOrderRepository {
  /// Fetches all orders for a specific business.
  Future<List<OrderModel>> getBusinessOrders(String businessId);

  /// Watches for real-time updates to business orders.
  Stream<List<OrderModel>> watchBusinessOrders(String businessId);

  /// Updates the status of an order.
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
}
