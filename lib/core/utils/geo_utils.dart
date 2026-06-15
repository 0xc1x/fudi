import 'dart:math' as math;

class GeoUtils {
  const GeoUtils._();

  static const _earthRadiusKm = 6371.0;

  static double haversineKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static String formatDistance(
    double? latitude,
    double? longitude, {
    double? userLat,
    double? userLng,
  }) {
    if (latitude == null || longitude == null) return '';
    if (userLat == null || userLng == null) return '';
    final km = haversineKm(userLat, userLng, latitude, longitude);
    if (km < 1) return '${(km * 1000).round()}m';
    return '${km.toStringAsFixed(1)}km';
  }

  static double _toRad(double deg) => deg * math.pi / 180;
}
