import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fudi/core/ui/fudi_pressable_scale.dart';

void main() {
  group('FudiPressableScale', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FudiPressableScale(
              onTap: () {},
              child: const Text('Presióname'),
            ),
          ),
        ),
      );

      expect(find.text('Presióname'), findsOneWidget);
    });

    testWidgets('triggers onTap when pressed', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FudiPressableScale(
              onTap: () => tapped = true,
              child: const Text('Presióname'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Presióname'));
      expect(tapped, isTrue);
    });
  });
}
