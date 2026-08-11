import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/features/offers/domain/category.dart';
import 'package:fudi/features/offers/domain/offer.dart';

void main() {
  const business = BusinessInfo(
    id: 'biz-1',
    name: 'Panadería Luis',
    type: 'bakery',
    rating: 4.5,
    address: 'Av. Siempre Viva 123',
  );

  Offer buildOffer({
    double originalPrice = 100,
    double discountedPrice = 75,
    int stock = 10,
    int initialStock = 10,
    bool isActive = true,
    List<Category> categories = const [],
    DateTime? pickupEnd,
  }) {
    return Offer(
      id: 'offer-1',
      businessId: 'biz-1',
      businessLocationId: 'loc-1',
      business: business,
      title: 'Canasta de pan',
      originalPrice: originalPrice,
      discountedPrice: discountedPrice,
      stock: stock,
      initialStock: initialStock,
      pickupStart: DateTime(2099),
      pickupEnd: pickupEnd ?? DateTime(2099, 12, 31),
      isActive: isActive,
      categories: categories,
    );
  }

  group('Offer', () {
    test('discountPercentage calcula el descuento relativo', () {
      final offer = buildOffer();
      expect(offer.discountPercentage, 25);
    });

    test('discountPercentage es 0 si el precio original es 0', () {
      final offer = buildOffer(originalPrice: 0);
      expect(offer.discountPercentage, 0);
    });

    test('categoryLabel une los nombres de las categorías', () {
      const categories = [
        Category(id: 'c1', name: 'Panadería'),
        Category(id: 'c2', name: 'Descuento'),
      ];
      final offer = buildOffer(categories: categories);
      expect(offer.categoryLabel, 'Panadería, Descuento');
    });

    test('isOutOfStock es true cuando el stock llega a cero', () {
      final offer = buildOffer(stock: 0);
      expect(offer.isOutOfStock, isTrue);
    });

    test('isAvailable requiere oferta activa con stock y pickup futuro', () {
      expect(buildOffer().isAvailable, isTrue);
      expect(buildOffer(isActive: false).isAvailable, isFalse);
      expect(buildOffer(stock: 0).isAvailable, isFalse);
    });

    test('isExpired es false con pickup en el futuro lejano', () {
      expect(buildOffer().isExpired, isFalse);
    });

    test('pickupUntilTimeOfDay extrae la hora del pickupEnd', () {
      final offer = buildOffer(
        pickupEnd: DateTime(2099, 12, 31, 18, 30),
      );
      expect(offer.pickupUntilTimeOfDay.hour, 18);
      expect(offer.pickupUntilTimeOfDay.minute, 30);
    });
  });
}
