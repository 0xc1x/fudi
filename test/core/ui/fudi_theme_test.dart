import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/ui/fudi_theme.dart';
import 'package:fudi/core/ui/fudi_surface_card.dart';
import 'package:fudi/core/ui/fudi_colors.dart';

void main() {
  group('FudiTheme light/dark parity', () {
    test('FudiTheme.light() has FudiThemeExtension', () {
      final theme = FudiTheme.light();
      final ext = theme.extensions.values.whereType<FudiThemeExtension>().firstOrNull;
      expect(ext, isNotNull, reason: 'light theme must include FudiThemeExtension');
      expect(ext!.cardBg, FudiColors.card);
    });

    test('FudiTheme.dark() has FudiThemeExtension with dark colors', () {
      final theme = FudiTheme.dark();
      final ext = theme.extensions.values.whereType<FudiThemeExtension>().firstOrNull;
      expect(ext, isNotNull, reason: 'dark theme must include FudiThemeExtension');
      expect(ext!.cardBg, FudiColorsDark.muted);
      expect(ext.border, FudiColorsDark.border);
    });

    test('light and dark themes have correct brightness', () {
      expect(FudiTheme.light().brightness, Brightness.light);
      expect(FudiTheme.dark().brightness, Brightness.dark);
    });
  });

  group('FudiSurfaceCard theme integration', () {
    Widget buildCard({required ThemeData theme}) {
      return MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: FudiSurfaceCard(
            child: Text('Test Card'),
          ),
        ),
      );
    }

    testWidgets('uses light card color by default', (tester) async {
      await tester.pumpWidget(buildCard(theme: FudiTheme.light()));

      // FudiSurfaceCard's own Container is the one with a BoxDecoration
      final decorated = tester.widgetList<Container>(find.byType(Container)).where(
        (c) => c.decoration is BoxDecoration,
      );
      expect(decorated, isNotEmpty);

      final decoration = decorated.first.decoration! as BoxDecoration;
      expect(decoration.color, FudiColors.card);
    });

    testWidgets('uses dark card color with dark theme', (tester) async {
      await tester.pumpWidget(buildCard(theme: FudiTheme.dark()));

      final decorated = tester.widgetList<Container>(find.byType(Container)).where(
        (c) => c.decoration is BoxDecoration,
      );
      expect(decorated, isNotEmpty);

      final decoration = decorated.first.decoration! as BoxDecoration;
      expect(decoration.color, FudiColorsDark.muted);
    });
  });
}
