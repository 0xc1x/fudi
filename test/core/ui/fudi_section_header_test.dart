import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/ui/fudi_section_header.dart';

void main() {
  group('FudiSectionHeader', () {
    testWidgets('renders the title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FudiSectionHeader(title: 'Ofertas')),
        ),
      );

      expect(find.text('Ofertas'), findsOneWidget);
    });

    testWidgets('hides "Ver todo" when no onSeeAll is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FudiSectionHeader(title: 'Ofertas')),
        ),
      );

      expect(find.text('Ver todo'), findsNothing);
    });

    testWidgets('shows and triggers "Ver todo" when onSeeAll is provided', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FudiSectionHeader(
              title: 'Ofertas',
              onSeeAll: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Ver todo'), findsOneWidget);

      await tester.tap(find.text('Ver todo'));
      expect(tapped, isTrue);
    });
  });
}
