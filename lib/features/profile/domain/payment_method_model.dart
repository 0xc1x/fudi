class PaymentMethodModel {
  const PaymentMethodModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
  });

  final String id;
  final String brand;
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final bool isDefault;

  PaymentMethodModel copyWith({
    String? id,
    String? brand,
    String? last4,
    int? expiryMonth,
    int? expiryYear,
    bool? isDefault,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'brand': brand,
    'last4': last4,
    'expiryMonth': expiryMonth,
    'expiryYear': expiryYear,
    'isDefault': isDefault,
  };

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      brand: json['brand'] as String,
      last4: json['last4'] as String,
      expiryMonth: json['expiryMonth'] as int,
      expiryYear: json['expiryYear'] as int,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
