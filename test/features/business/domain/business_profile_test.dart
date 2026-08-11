import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/features/business/domain/business_profile.dart';

void main() {
  group('BusinessProfile', () {
    const profile = BusinessProfile(
      id: 'biz-1',
      name: 'Panadería Luis',
      type: 'bakery',
      rating: 4.5,
      reviewCount: 12,
      totalRescued: 87,
    );

    test('defaults para conteos cuando no se proveen', () {
      const empty = BusinessProfile(
        id: 'biz-2',
        name: 'Café',
        type: 'cafe',
        rating: 4.0,
      );
      expect(empty.reviewCount, 0);
      expect(empty.totalRescued, 0);
    });

    test('toInfo mapea los campos principales', () {
      final info = profile.toInfo();
      expect(info.id, 'biz-1');
      expect(info.name, 'Panadería Luis');
      expect(info.type, 'bakery');
      expect(info.rating, 4.5);
    });

    test('toInfo usa cadena vacia como address cuando no hay dirección', () {
      final info = profile.toInfo();
      expect(info.address, '');
    });
  });
}
