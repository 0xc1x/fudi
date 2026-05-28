enum BusinessPayoutStatus {
  pending,
  processing,
  paid,
  failed;

  static BusinessPayoutStatus fromString(String? value) => switch (value) {
    'processing' => BusinessPayoutStatus.processing,
    'paid' => BusinessPayoutStatus.paid,
    'failed' => BusinessPayoutStatus.failed,
    _ => BusinessPayoutStatus.pending,
  };

  String get label => switch (this) {
    BusinessPayoutStatus.pending => 'Pendiente',
    BusinessPayoutStatus.processing => 'Procesando',
    BusinessPayoutStatus.paid => 'Pagado',
    BusinessPayoutStatus.failed => 'Fallido',
  };
}

class BusinessPayout {
  const BusinessPayout({
    required this.id,
    required this.businessId,
    required this.periodStart,
    required this.periodEnd,
    required this.grossAmount,
    required this.platformFee,
    required this.netAmount,
    required this.status,
    this.gatewayPayoutId,
    this.paidAt,
    this.createdAt,
  });

  final String id;
  final String businessId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double grossAmount;
  final double platformFee;
  final double netAmount;
  final BusinessPayoutStatus status;
  final String? gatewayPayoutId;
  final DateTime? paidAt;
  final DateTime? createdAt;
}
