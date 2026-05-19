class SavedAddressModel {
  const SavedAddressModel({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;
}
