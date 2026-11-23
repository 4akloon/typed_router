import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router_example/catalogue/catalogue.dart';
import 'package:typed_router_example/example_app.dart';

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

        expect(find.text('typed_router scenarios'), findsOneWidget);
      });
    }
  }
}
