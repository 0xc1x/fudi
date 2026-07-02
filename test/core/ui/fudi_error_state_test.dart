import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/ui/fudi_error_state.dart';

void main() {
  group('FudiErrorState', () {
    testWidgets('renders error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FudiErrorState(
              message: 'Error de conexión',
              key: Key('error_state'),
            ),
          ),
        ),
      );

      expect(find.text('Error al cargar'), findsOneWidget);
      expect(find.text('Error de conexión'), findsOneWidget);
    });

    testWidgets('renders retry button when onRetry is provided', (
      tester,
    ) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FudiErrorState(
              message: 'Error',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Reintentar'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      expect(retried, isTrue);
    });

    testWidgets('does not render retry button when onRetry is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FudiErrorState(message: 'Error')),
        ),
      );

      expect(find.text('Reintentar'), findsNothing);
    });
  });
}
