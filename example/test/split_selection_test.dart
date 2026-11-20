import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator_example/scenarios/split_view_list_detail_scenario.dart';
import 'package:typed_navigator_example/scenarios/split_view_miller_scenario.dart';

import 'support/catalogue_driver.dart';

/// Makes the window [width] logical pixels wide.
void _windowWidth(WidgetTester tester, double width) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 1000);
  addTearDown(tester.view.reset);
}

/// Whether the list tile labelled [label] is selected; [label] must name
/// exactly one tile.
bool _isSelected(WidgetTester tester, String label) =>
    tester.widget<ListTile>(find.widgetWithText(ListTile, label)).selected;

/// Whether the first list tile labelled [label] is selected.
bool _isSelectedFirst(WidgetTester tester, String label) => tester
    .widget<ListTile>(find.widgetWithText(ListTile, label).first)
    .selected;

void main() {
  testWidgets('the rooms list highlights the room open beside it', (
    tester,
  ) async {
    _windowWidth(tester, 1200);
    await startScenario(tester, splitViewListDetailScenario);
    await tapLabel(tester, 'go to the rooms');
    await tapLabel(tester, 'Room 2');

    await tapLabel(tester, 'Room 4');

    expect(_isSelected(tester, 'Room 4'), isTrue);
    expect(_isSelected(tester, 'Room 2'), isFalse);
  });

  testWidgets('a Miller column highlights the folder open beside it', (
    tester,
  ) async {
    _windowWidth(tester, 1200);
    await startScenario(tester, splitViewMillerScenario);

    await tapLabel(tester, 'Alpha');
    await tester.tap(find.text('Gamma').first);
    await tester.pumpAndSettle();

    // The home column comes first in the tree.
    expect(_isSelectedFirst(tester, 'Gamma'), isTrue);
    expect(_isSelectedFirst(tester, 'Alpha'), isFalse);
  });
}
