import 'profile_models.dart' show AddressType, HousingType;
export 'profile_models.dart' show AddressType, HousingType;

class SavedAddressModel {
  const SavedAddressModel({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    this.type = AddressType.other,
    this.references,
    this.housingType,
  });

  final String id;
  final String label;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final AddressType type;
  final String? references;
  final HousingType? housingType;
}
