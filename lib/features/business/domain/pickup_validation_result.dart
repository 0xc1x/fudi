class PickupValidationResult {
  const PickupValidationResult({
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
