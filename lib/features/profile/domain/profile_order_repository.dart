import 'user_order.dart';

abstract class ProfileOrderRepository {
  Future<UserStats> getUserStats(String userId);

  Future<List<UserOrder>> getUserOrders(String userId);
}
