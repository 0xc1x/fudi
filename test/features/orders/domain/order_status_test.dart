import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/features/orders/domain/order_status.dart';

void main() {
  group('OrderStatus.fromString', () {
    test('mapea valores de BD al enum', () {
      expect(OrderStatus.fromString('pending'), OrderStatus.pending);
      expect(OrderStatus.fromString('confirmed'), OrderStatus.confirmed);
      expect(
        OrderStatus.fromString('ready_for_pickup'),
        OrderStatus.readyForPickup,
      );
      expect(OrderStatus.fromString('picked_up'), OrderStatus.pickedUp);
      expect(OrderStatus.fromString('completed'), OrderStatus.completed);
      expect(OrderStatus.fromString('cancelled'), OrderStatus.cancelled);
      expect(OrderStatus.fromString('expired'), OrderStatus.expired);
    });

    test('null o desconocido cae a pending', () {
      expect(OrderStatus.fromString(null), OrderStatus.pending);
      expect(OrderStatus.fromString('inventado'), OrderStatus.pending);
    });

    test('dbValue serializa snake_case', () {
      expect(OrderStatus.readyForPickup.dbValue, 'ready_for_pickup');
      expect(OrderStatus.pickedUp.dbValue, 'picked_up');
      expect(OrderStatus.pending.dbValue, 'pending');
      expect(OrderStatus.completed.dbValue, 'completed');
    });
  });

  group('OrderStatus.canTransitionTo', () {
    test('pending solo avanza aceptando/confirmando', () {
      expect(OrderStatus.pending.canTransitionTo(OrderStatus.confirmed), isTrue);
      expect(OrderStatus.pending.canTransitionTo(OrderStatus.cancelled), isTrue);
      expect(OrderStatus.pending.canTransitionTo(OrderStatus.expired), isTrue);
      expect(OrderStatus.pending.canTransitionTo(OrderStatus.readyForPickup), isFalse);
      expect(OrderStatus.pending.canTransitionTo(OrderStatus.pickedUp), isFalse);
      expect(OrderStatus.pending.canTransitionTo(OrderStatus.completed), isFalse);
    });

    test('confirmed avanza a readyForPickup o se cancela/expira', () {
      expect(
        OrderStatus.confirmed.canTransitionTo(OrderStatus.readyForPickup),
        isTrue,
      );
      expect(OrderStatus.confirmed.canTransitionTo(OrderStatus.cancelled), isTrue);
      expect(OrderStatus.confirmed.canTransitionTo(OrderStatus.expired), isTrue);
      expect(OrderStatus.confirmed.canTransitionTo(OrderStatus.pickedUp), isFalse);
      expect(OrderStatus.confirmed.canTransitionTo(OrderStatus.completed), isFalse);
    });

    test('readyForPickup avanza solo a pickedUp/completed o terminales', () {
      expect(OrderStatus.readyForPickup.canTransitionTo(OrderStatus.pickedUp), isTrue);
      expect(
        OrderStatus.readyForPickup.canTransitionTo(OrderStatus.completed),
        isTrue,
      );
      expect(
        OrderStatus.readyForPickup.canTransitionTo(OrderStatus.cancelled),
        isTrue,
      );
      expect(
        OrderStatus.readyForPickup.canTransitionTo(OrderStatus.expired),
        isTrue,
      );
    });

    test('pickedUp solo a completed', () {
      expect(OrderStatus.pickedUp.canTransitionTo(OrderStatus.completed), isTrue);
      expect(OrderStatus.pickedUp.canTransitionTo(OrderStatus.cancelled), isFalse);
      expect(OrderStatus.pickedUp.canTransitionTo(OrderStatus.pickedUp), isFalse);
    });

    test('estados terminales no transicionan', () {
      expect(OrderStatus.completed.canTransitionTo(OrderStatus.pickedUp), isFalse);
      expect(OrderStatus.cancelled.canTransitionTo(OrderStatus.confirmed), isFalse);
      expect(OrderStatus.expired.canTransitionTo(OrderStatus.pending), isFalse);
    });
  });

  group('OrderStatus terminales/activos', () {
    test('completed/cancelled/expired son terminales', () {
      expect(OrderStatus.completed.isTerminal, isTrue);
      expect(OrderStatus.cancelled.isTerminal, isTrue);
      expect(OrderStatus.expired.isTerminal, isTrue);
    });

    test('el resto son activos', () {
      expect(OrderStatus.pending.isActive, isTrue);
      expect(OrderStatus.confirmed.isActive, isTrue);
      expect(OrderStatus.readyForPickup.isActive, isTrue);
      expect(OrderStatus.pickedUp.isActive, isTrue);
      expect(OrderStatus.completed.isActive, isFalse);
    });

    test('label es humanamente legible', () {
      expect(OrderStatus.readyForPickup.label, 'Listo para recoger');
      expect(OrderStatus.cancelled.label, 'Cancelado');
      expect(OrderStatus.pending.label, 'Pendiente');
    });
  });
}