import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator_example/catalogue/catalogue.dart';
import 'package:typed_navigator_example/example_app.dart';

import 'support/catalogue_driver.dart';

void main() {
  for (final section in catalogue) {
    for (final scenario in section.scenarios) {
      testWidgets('the catalogue opens and closes "${scenario.title}"', (
        tester,
      ) async {
        await tester.pumpWidget(const ExampleApp());

        await openScenario(tester, scenario);

        expect(tester.takeException(), isNull);
        expect(find.textContaining('State: '), findsOneWidget);
        expect(find.text('• ${scenario.instructions.first}'), findsOneWidget);

        await tester.tap(find.text('Close demo'));
        await tester.pumpAndSettle();

        expect(find.text('typed_navigator scenarios'), findsOneWidget);
      });
    }
  }

  testWidgets('the split view section shows its placeholder while empty', (
    tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());

    await tester.scrollUntilVisible(
      find.text('0.4 Split view'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Coming with SplitNode.'), findsOneWidget);
  });
}
