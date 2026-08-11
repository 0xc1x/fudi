import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/features/orders/domain/coupon.dart';

void main() {
  group('Coupon.fromJson', () {
    test('parsea todos los campos', () {
      final coupon = Coupon.fromJson({
        'id': 'c-1',
        'business_id': 'b-1',
        'code': 'FUDI10',
        'name': '10% off',
        'type': 'percentage',
        'value': 10,
        'min_order_amount': 50,
        'max_uses': 100,
        'used_count': 3,
        'is_active': true,
        'expires_at': '2030-01-01T00:00:00.000Z',
      });

      expect(coupon.id, 'c-1');
      expect(coupon.businessId, 'b-1');
      expect(coupon.code, 'FUDI10');
      expect(coupon.type, 'percentage');
      expect(coupon.value, 10);
      expect(coupon.minOrderAmount, 50);
      expect(coupon.maxUses, 100);
      expect(coupon.usedCount, 3);
      expect(coupon.isActive, isTrue);
      expect(coupon.expiresAt, isNotNull);
    });

    test('usa defaults cuando faltan campos opcionales', () {
      final coupon = Coupon.fromJson({
        'id': 'c-2',
        'business_id': 'b-1',
        'code': 'X',
        'name': 'X',
        'type': 'fixed',
        'value': 5,
      });
      expect(coupon.minOrderAmount, 0);
      expect(coupon.maxUses, isNull);
      expect(coupon.usedCount, 0);
      expect(coupon.isActive, isTrue);
      expect(coupon.expiresAt, isNull);
    });
  });

  group('Coupon.validez', () {
    Coupon coupon({bool active = true, DateTime? expiresAt, int? maxUses, int used = 0}) {
      return Coupon(
        id: 'c-1',
        businessId: 'b-1',
        code: 'FUDI10',
        name: 'Cupon',
        type: 'percentage',
        value: 10,
        maxUses: maxUses,
        usedCount: used,
        isActive: active,
        expiresAt: expiresAt,
      );
    }

    test('isExpired con fecha pasada', () {
      expect(
        coupon(expiresAt: DateTime.now().subtract(const Duration(days: 1))).isExpired,
        isTrue,
      );
      expect(
        coupon(expiresAt: DateTime.now().add(const Duration(days: 1))).isExpired,
        isFalse,
      );
      expect(coupon().isExpired, isFalse, reason: 'sin fecha no expira');
    });

    test('isExhausted al alcanzar maxUses', () {
      expect(coupon(maxUses: 5, used: 5).isExhausted, isTrue);
      expect(coupon(maxUses: 5, used: 4).isExhausted, isFalse);
      expect(coupon().isExhausted, isFalse, reason: 'sin limite no se agota');
    });

    test('isValid exige activo, vigente y disponible', () {
      expect(coupon().isValid, isTrue);
      expect(coupon(active: false).isValid, isFalse);
      expect(
        coupon(expiresAt: DateTime.now().subtract(const Duration(days: 1))).isValid,
        isFalse,
      );
      expect(coupon(maxUses: 1, used: 1).isValid, isFalse);
    });
  });

  group('Coupon.calculateDiscount', () {
    test('porcentaje: valor * % / 100 sin exceder el precio', () {
      const pct = Coupon(
        id: 'c-1',
        businessId: 'b-1',
        code: 'PCT',
        name: 'P',
        type: 'percentage',
        value: 25,
      );
      expect(pct.calculateDiscount(80), 20);
      expect(pct.calculateDiscount(100), 25);
      expect(pct.calculateDiscount(10), 2.5);
    });

    test('porcentaje con clamp en precios bajos', () {
      const pct = Coupon(
        id: 'c-1',
        businessId: 'b-1',
        code: 'PCT',
        name: 'P',
        type: 'percentage',
        value: 50,
      );
      expect(pct.calculateDiscount(5), 2.5);
    });

    test('fijo: descuenta el valor sin pasarse del precio', () {
      const fixed = Coupon(
        id: 'c-1',
        businessId: 'b-1',
        code: 'FIX',
        name: 'F',
        type: 'fixed',
        value: 30,
      );
      expect(fixed.calculateDiscount(100), 30);
      expect(fixed.calculateDiscount(20), 20, reason: 'clamp al precio');
      expect(fixed.calculateDiscount(0), 0);
    });
  });
}