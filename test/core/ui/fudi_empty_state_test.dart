import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/ui/fudi_empty_state.dart';

void main() {
  group('FudiEmptyState', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FudiEmptyState(
              title: 'Sin resultados',
              description: 'No se encontraron elementos.',
            ),
          ),
        ),
      );

      expect(find.text('Sin resultados'), findsOneWidget);
      expect(find.text('No se encontraron elementos.'), findsOneWidget);
    });

    testWidgets('renders action button when provided', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FudiEmptyState(
              title: 'Vacío',
              description: 'No hay items.',
              actionLabel: 'Recargar',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Recargar'), findsOneWidget);

      await tester.tap(find.text('Recargar'));
      expect(tapped, isTrue);
    });

    testWidgets('does not render action when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FudiEmptyState(title: 'Vacío', description: 'No hay items.'),
          ),
        ),
      );

      expect(find.text('Recargar'), findsNothing);
    });
  });
}
