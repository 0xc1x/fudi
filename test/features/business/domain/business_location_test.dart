import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/features/business/domain/business_location.dart';

void main() {
  group('BusinessLocation', () {
    test('uses persisted active flag instead of UI defaults', () {
      final location = BusinessLocation(
        id: 'loc-1',
        businessId: 'biz-1',
        name: 'Sede norte',
        address: 'Calle 1 #2-3',
        isActive: false,
      );

      expect(location.isActive, isFalse);
      expect(location.hasCoordinates, isFalse);
    });

    test('detects real coordinates when both latitude and longitude exist', () {
      final location = BusinessLocation(
        id: 'loc-1',
        businessId: 'biz-1',
        name: 'Sede norte',
        address: 'Calle 1 #2-3',
        latitude: 4.7,
        longitude: -74.1,
      );

      expect(location.hasCoordinates, isTrue);
    });
  });
}
