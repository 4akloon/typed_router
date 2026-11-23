import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router_example/scenarios/stack_operations_scenario.dart';

import 'support/catalogue_driver.dart';

/// Scrolls the step's page until [label] is built: its list builds the
/// buttons below the fold lazily.
Future<void> _scrollTo(WidgetTester tester, String label) =>
    tester.scrollUntilVisible(
      find.text(label),
      100,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );

void main() {
  testWidgets('replace updates the step in place, pushReplacement slides a '
      'new one, router.pop closes a dialog first', (tester) async {
    await startScenario(tester, stackOperationsScenario);
    await tapLabel(tester, 'push step 2');

    await tapLabel(tester, 'replace with step 12');
    expect(shownState(tester), 'StepRoute(1) > StepRoute(12)');
    expect(find.text('Step 12'), findsOneWidget);

    await tapLabel(tester, 'pushReplacement with step 32');
    expect(shownState(tester), 'StepRoute(1) > StepRoute(32)');

    await _scrollTo(tester, 'open a dialog');
    await tapLabel(tester, 'open a dialog');
    expect(find.text('A dialog above the step'), findsOneWidget);
    await tapLabel(tester, 'router.pop');
    expect(find.text('A dialog above the step'), findsNothing);
    expect(shownState(tester), 'StepRoute(1) > StepRoute(32)');

    await tapLabel(tester, 'popUntil step 1');
    await tapLabel(tester, 'replace with step 11');
    await _scrollTo(tester, 'pushAndRemoveUntil step 99');
    await tapLabel(tester, 'pushAndRemoveUntil step 99');
    expect(shownState(tester), 'StepRoute(99)');
  });
}
