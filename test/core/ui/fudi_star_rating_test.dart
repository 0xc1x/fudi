import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/ui/fudi_star_rating.dart';

void main() {
  group('FudiStarRating', () {
    testWidgets('renders the widget without text by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FudiStarRating(rating: 4)),
        ),
      );

      expect(find.byType(FudiStarRating), findsOneWidget);
      expect(find.text('4.0'), findsNothing);
    });

    testWidgets('shows rating text formatted to one decimal when showText', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FudiStarRating(rating: 3.5, showText: true)),
        ),
      );

      expect(find.text('3.5'), findsOneWidget);
    });

    testWidgets('triggers onTap with the tapped star index', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FudiStarRating(rating: 0, onTap: (value) => tapped = value),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell).first);
      expect(tapped, 1);
    });
  });
}
