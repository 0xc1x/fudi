import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/ui/fudi_responsive.dart';

void main() {
  group('FudiBreakpoints', () {
    test('isCompact returns true for widths below compact breakpoint', () {
      expect(FudiBreakpoints.isCompact(599), isTrue);
      expect(FudiBreakpoints.isCompact(400), isTrue);
      expect(FudiBreakpoints.isCompact(0), isTrue);
    });

    test('isCompact returns false for widths at or above compact breakpoint', () {
      expect(FudiBreakpoints.isCompact(600), isFalse);
      expect(FudiBreakpoints.isCompact(800), isFalse);
    });

    test('isMedium returns true for widths between compact and medium', () {
      expect(FudiBreakpoints.isMedium(600), isTrue);
      expect(FudiBreakpoints.isMedium(700), isTrue);
      expect(FudiBreakpoints.isMedium(839), isTrue);
    });

    test('isMedium returns false outside range', () {
      expect(FudiBreakpoints.isMedium(599), isFalse);
      expect(FudiBreakpoints.isMedium(840), isFalse);
    });

    test('isExpanded returns true for widths at or above expanded breakpoint', () {
      expect(FudiBreakpoints.isExpanded(840), isTrue);
      expect(FudiBreakpoints.isExpanded(1200), isTrue);
    });

    test('screenType returns correct enum', () {
      expect(FudiBreakpoints.screenType(400), ScreenType.compact);
      expect(FudiBreakpoints.screenType(700), ScreenType.medium);
      expect(FudiBreakpoints.screenType(1000), ScreenType.expanded);
    });
  });

  group('FudiResponsiveBuilder', () {
    testWidgets('renders compact layout for small constraints', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: FudiResponsiveBuilder(
                compact: (_) => const Text('Compact Layout'),
                expanded: (_) => const Text('Expanded Layout'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Compact Layout'), findsOneWidget);
      expect(find.text('Expanded Layout'), findsNothing);
    });
  });
}
