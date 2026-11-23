import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router_example/catalogue/scenario.dart';
import 'package:typed_router_example/example_app.dart';

/// Scrolls the catalogue to [scenario] and opens it.
Future<void> openScenario(WidgetTester tester, Scenario scenario) async {
  final entry = find.byKey(ValueKey(scenario.title));
  await tester.scrollUntilVisible(
    entry,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(entry);
  await tester.pumpAndSettle();
  await tester.tap(entry);
  await tester.pumpAndSettle();
}

/// Starts the example with [scenario] open.
Future<void> startScenario(WidgetTester tester, Scenario scenario) async {
  await tester.pumpWidget(const ExampleApp());
  await openScenario(tester, scenario);
}

/// Taps the button labelled [label], or the text itself when no button
/// has it (a tab, a list tile), and lets the navigation end.
Future<void> tapLabel(WidgetTester tester, String label) async {
  final button = find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
  );
  await tester.tap(button.evaluate().isEmpty ? find.text(label) : button);
  await tester.pumpAndSettle();
}

/// The router's state as the instructions panel shows it.
String shownState(WidgetTester tester) {
  final line = tester.widget<Text>(find.textContaining('State: '));
  return (line.data ?? '').substring('State: '.length);
}
