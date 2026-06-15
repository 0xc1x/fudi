class Coupon {
  const Coupon({
    required this.id,
    required this.businessId,
    required this.code,
    required this.name,
    required this.type,
    required this.value,
    this.minOrderAmount = 0,
    this.maxUses,
    this.usedCount = 0,
    this.isActive = true,
    this.expiresAt,
  });

  final String id;
  final String businessId;
  final String code;
  final String name;
  final String type; // percentage, fixed
  final double value;
  final double minOrderAmount;
  final int? maxUses;
  final int usedCount;
  final bool isActive;
  final DateTime? expiresAt;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isExhausted => maxUses != null && usedCount >= maxUses!;
  bool get isValid => isActive && !isExpired && !isExhausted;

  double calculateDiscount(double price) {
    if (type == 'percentage') {
      return (price * value / 100).clamp(0, price);
    } else {
      return value.clamp(0, price);
    }
  }

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      minOrderAmount: (json['min_order_amount'] as num? ?? 0).toDouble(),
      maxUses: json['max_uses'] as int?,
      usedCount: json['used_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }
}
