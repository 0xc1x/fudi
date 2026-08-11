import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/ui/atoms/fudi_discount_badge.dart';
import 'package:fudi/core/ui/fudi_colors.dart';
import 'package:fudi/core/ui/fudi_theme.dart';

void main() {
  group('FudiDiscountBadge', () {
    testWidgets('renders discount percentage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FudiDiscountBadge(percent: 30, key: Key('badge')),
          ),
        ),
      );

      expect(find.text('-30%'), findsOneWidget);
    });

    testWidgets('renders 0% discount', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FudiDiscountBadge(percent: 0, key: Key('badge')),
          ),
        ),
      );

      expect(find.text('-0%'), findsOneWidget);
    });

    testWidgets('renders with custom background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FudiDiscountBadge(percent: 50, backgroundColor: Colors.blue),
          ),
        ),
      );

      expect(find.text('-50%'), findsOneWidget);
    });
  });

  group('FudiDiscountBadge styling', () {
    testWidgets('uses default primary color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: FudiTheme.light(),
          home: const Scaffold(
            body: FudiDiscountBadge(percent: 20),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, FudiColors.primary);
    });
  });
}
