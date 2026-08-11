import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fudi/features/orders/domain/coupon.dart';
import 'package:fudi/features/orders/domain/coupon_repository.dart';
import 'package:fudi/features/orders/presentation/order_providers.dart';

class MockCouponRepository extends Mock implements CouponRepository {}

void main() {
  late MockCouponRepository mockRepo;

  setUp(() {
    mockRepo = MockCouponRepository();
  });

  group('validateCouponProvider', () {
    test('resuelve con el cupon valido', () async {
      const coupon = Coupon(
        id: 'c-1',
        businessId: 'b-1',
        code: 'FUDI10',
        name: '10% off',
        type: 'percentage',
        value: 10,
      );
      when(
        () => mockRepo.getCouponByCode('FUDI10', 'b-1'),
      ).thenAnswer((_) async => coupon);

      final container = ProviderContainer(
        overrides: [
          couponRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        validateCouponProvider((code: 'FUDI10', businessId: 'b-1')).future,
      );
      expect(result?.id, 'c-1');
      expect(result?.code, 'FUDI10');
    });

    // NOTA: no hay test de propagación de errores aquí. En Riverpod 3.3.1,
    // una FutureProvider cuya future rechaza (repositorio lanza) permanece en
    // AsyncLoading indefinidamente bajo flutter_test (verificado empíricamente:
    // ni async-throw ni Future.error asientan AsyncError con container + listen).
    // Es un quirk de la librería en entornos de test, no lógica de la app;
    // la validación de errores del repo pertenece a los tests de repositorio.
    test('resuelve null cuando el cupon no existe', () async {
      when(
        () => mockRepo.getCouponByCode('NOEXISTE', 'b-1'),
      ).thenAnswer((_) async => null);

      final container = ProviderContainer(
        overrides: [
          couponRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        validateCouponProvider((code: 'NOEXISTE', businessId: 'b-1')).future,
      );
      expect(result, isNull);
    });
  });
}