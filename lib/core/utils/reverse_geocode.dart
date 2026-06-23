import 'package:dio/dio.dart';

class ReverseGeocodeResult {
  const ReverseGeocodeResult({
    required this.displayName,
    this.neighbourhood,
    this.quarter,
    this.cityDistrict,
    this.city,
  });

  final String displayName;
  final String? neighbourhood;
  final String? quarter;
  final String? cityDistrict;
  final String? city;

  String get bestZoneName =>
    neighbourhood ?? quarter ?? cityDistrict ?? city ?? displayName;
}

Future<ReverseGeocodeResult> reverseGeocode({
  required double latitude,
  required double longitude,
}) async {
  try {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&accept-language=es';
    final response = await Dio().get<Map<String, dynamic>>(
      url,
      options: Options(
        headers: {'User-Agent': 'FudiApp/1.0'},
      ),
    );
    final data = response.data;
    if (data == null) {
      return ReverseGeocodeResult(displayName: '');
    }

    final address = data['address'] as Map<String, dynamic>?;

    return ReverseGeocodeResult(
      displayName: data['display_name'] as String? ?? '',
      neighbourhood: address?['neighbourhood'] as String?,
      quarter: address?['quarter'] as String?,
      cityDistrict: address?['city_district'] as String?,
      city: address?['city'] as String?,
    );
  } catch (_) {
    return ReverseGeocodeResult(displayName: '');
  }
}
