import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator_example/scenarios/split_view_custom_layout_scenario.dart';
import 'package:typed_navigator_example/scenarios/split_view_list_detail_scenario.dart';
import 'package:typed_navigator_example/scenarios/split_view_miller_scenario.dart';

import 'support/catalogue_driver.dart';

/// Makes the window [width] logical pixels wide.
void _windowWidth(WidgetTester tester, double width) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 1000);
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('a wide split shows the rooms beside the placeholder, then '
      'beside a room', (tester) async {
    _windowWidth(tester, 1200);
    await startScenario(tester, splitViewListDetailScenario);
    await tapLabel(tester, 'go to the rooms');
    expect(find.text('Pick a room'), findsOneWidget);

    await tapLabel(tester, 'Room 2');

    expect(shownState(tester), '[RoomsRoute() > RoomRoute(2)]');
    expect(find.text('Pick a room'), findsNothing);
    expect(find.text('Rooms'), findsOneWidget);
  });

  testWidgets('Navigator.pop in a column closes it and the ones to its '
      'right', (tester) async {
    _windowWidth(tester, 1200);
    await startScenario(tester, splitViewListDetailScenario);
    await tapLabel(tester, 'go to the rooms');
    await tapLabel(tester, 'Room 2');
    await tapLabel(tester, 'push room 3');
    expect(shownState(tester), '[RoomsRoute() > RoomRoute(2) > RoomRoute(3)]');

    await tester.tap(find.text('Navigator.pop this column').first);
    await tester.pumpAndSettle();

    expect(shownState(tester), '[RoomsRoute()]');
  });

  testWidgets('a narrow split is a stack', (tester) async {
    _windowWidth(tester, 500);
    await startScenario(tester, splitViewListDetailScenario);
    await tapLabel(tester, 'go to the rooms');

    await tapLabel(tester, 'Room 2');

    expect(find.text('Pick a room'), findsNothing);
    expect(find.text('Rooms'), findsNothing);
    await tapLabel(tester, 'System back');
    expect(shownState(tester), '[RoomsRoute()]');
  });

  testWidgets('Miller columns open folders side by side', (tester) async {
    _windowWidth(tester, 1200);
    await startScenario(tester, splitViewMillerScenario);

    await tapLabel(tester, 'Alpha');
    await tester.tap(find.text('Beta').last);
    await tester.pumpAndSettle();

    expect(
      shownState(tester),
      '[FolderRoute(Home) > FolderRoute(Home/Alpha) > '
      'FolderRoute(Home/Alpha/Beta)]',
    );
    expect(find.text('Pick a folder'), findsOneWidget);
  });

  testWidgets('the back button of a middle Miller column closes it and '
      'the ones to its right', (tester) async {
    _windowWidth(tester, 1200);
    await startScenario(tester, splitViewMillerScenario);
    await tapLabel(tester, 'Alpha');
    await tester.tap(find.text('Beta').last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.widgetWithText(AppBar, 'Alpha'),
        matching: find.byType(BackButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(shownState(tester), '[FolderRoute(Home)]');
  });

  testWidgets('a custom layout labels the typed columns', (tester) async {
    _windowWidth(tester, 1200);
    await startScenario(tester, splitViewCustomLayoutScenario);

    expect(find.text('RouteColumn: RoomsRoute()'), findsOneWidget);
    expect(find.text('PlaceholderColumn of RoomsRoute()'), findsOneWidget);
  });
}
