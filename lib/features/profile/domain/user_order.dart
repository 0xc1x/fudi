class UserOrder {
  const UserOrder({
    required this.id,
    required this.orderNumber,
    required this.businessName,
    required this.status,
    required this.price,
    required this.originalPrice,
    required this.pickupTime,
    required this.createdAt,
    this.offerImageUrl,
  });

  final String id;
  final String orderNumber;
  final String businessName;
  final OrderStatus status;
  final double price;
  final double originalPrice;
  final DateTime? pickupTime;
  final DateTime createdAt;
  final String? offerImageUrl;

  double get savedAmount => originalPrice - price;

  double get discountPercentage =>
      originalPrice > 0 ? ((originalPrice - price) / originalPrice * 100) : 0;
}

enum OrderStatus {
  pending,
  confirmed,
  readyForPickup,
  pickedUp,
  completed,
  cancelled,
  expired;

  static OrderStatus fromString(String? value) {
    return switch (value) {
      'pending' => OrderStatus.pending,
      'confirmed' => OrderStatus.confirmed,
      'ready_for_pickup' => OrderStatus.readyForPickup,
      'picked_up' => OrderStatus.pickedUp,
      'completed' => OrderStatus.completed,
      'cancelled' => OrderStatus.cancelled,
      'expired' => OrderStatus.expired,
      _ => OrderStatus.pending,
    };
  }

  bool get isUpcoming =>
      this == OrderStatus.pending ||
      this == OrderStatus.confirmed ||
      this == OrderStatus.readyForPickup;

  bool get isPast =>
      this == OrderStatus.completed ||
      this == OrderStatus.pickedUp ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.expired;
}

class UserStats {
  const UserStats({
    required this.totalSaved,
    required this.totalOrders,
    required this.co2SavedKg,
  });

  final double totalSaved;
  final int totalOrders;
  final double co2SavedKg;

  static const empty = UserStats(totalSaved: 0, totalOrders: 0, co2SavedKg: 0);
}
