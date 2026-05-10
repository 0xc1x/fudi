sealed class ReservationResult {
  const ReservationResult();
}

class ReservationSuccess extends ReservationResult {
  const ReservationSuccess({
    required this.orderId,
    required this.orderNumber,
    required this.pickupCode,
    required this.price,
    required this.originalPrice,
    required this.discount,
  });

  final String orderId;
  final String orderNumber;
  final String pickupCode;
  final double price;
  final double originalPrice;
  final double discount;
}

class ReservationFailure extends ReservationResult {
  const ReservationFailure({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;

  bool get isOfferNotFound => errorCode == 'OFFER_NOT_FOUND';
  bool get isOutOfStock => errorCode == 'OFFER_OUT_OF_STOCK';
  bool get isExpired => errorCode == 'OFFER_EXPIRED';
  bool get isDuplicate => errorCode == 'DUPLICATE_RESERVATION';
  bool get isCouponExhausted => errorCode == 'COUPON_EXHAUSTED';
  bool get isCouponMinNotMet => errorCode == 'COUPON_MIN_NOT_MET';
}
