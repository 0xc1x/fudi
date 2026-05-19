import 'order_status.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.offerId,
    required this.businessId,
    required this.orderNumber,
    required this.status,
    required this.price,
    required this.originalPrice,
    required this.pickupCode,
    required this.createdAt,
    required this.offerTitle,
    required this.businessName,
    this.pickupTime,
    this.couponId,
    this.offerImageUrl,
    this.businessAddress,
    this.businessPhone,
  });

  final String id;
  final String userId;
  final String offerId;
  final String businessId;
  final String orderNumber;
  final OrderStatus status;
  final double price;
  final double originalPrice;
  final String pickupCode;
  final DateTime? pickupTime;
  final String? couponId;
  final DateTime createdAt;

  final String offerTitle;
  final String? offerImageUrl;
  final String businessName;
  final String? businessAddress;
  final String? businessPhone;

  double get discount => originalPrice - price;

  double get discountPercentage =>
      originalPrice > 0 ? (discount / originalPrice * 100) : 0;
}
