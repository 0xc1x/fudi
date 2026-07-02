import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/ui/atoms/fudi_status_badge.dart';

void main() {
  group('FudiStatusBadge', () {
    testWidgets('renders with label and default style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FudiStatusBadge(label: 'Activo', color: Colors.green),
          ),
        ),
      );

      expect(find.text('Activo'), findsOneWidget);
    });

    testWidgets('renders active badge via factory', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: FudiStatusBadge.active())),
      );

      expect(find.text('Activo'), findsOneWidget);
    });

    testWidgets('renders inactive badge via factory', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FudiStatusBadge.active(isActive: false)),
        ),
      );

      expect(find.text('Inactivo'), findsOneWidget);
    });

    testWidgets('renders order status labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FudiStatusBadge.fromOrderStatus('confirmed')),
        ),
      );

      expect(find.text('Confirmado'), findsOneWidget);
    });
  });
}
