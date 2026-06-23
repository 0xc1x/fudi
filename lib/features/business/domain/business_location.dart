class BusinessLocation {
  const BusinessLocation({
    required this.id,
    required this.businessId,
    required this.name,
    required this.address,
    this.phone,
    this.latitude,
    this.longitude,
    this.zone,
    this.isHeadquarter = false,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String businessId;
  final String name;
  final String address;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String? zone;
  final bool isHeadquarter;
  final bool isActive;
  final DateTime? createdAt;

  bool get hasCoordinates => latitude != null && longitude != null;
}
