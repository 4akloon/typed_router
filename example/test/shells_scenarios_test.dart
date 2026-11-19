import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator_example/scenarios/navigator_slots_scenario.dart';
import 'package:typed_navigator_example/scenarios/shell_scenario.dart';
import 'package:typed_navigator_example/scenarios/tabs_page_view_scenario.dart';
import 'package:typed_navigator_example/scenarios/tabs_scenario.dart';

import 'support/catalogue_driver.dart';

void main() {
  testWidgets('letters open inside the shell and back pops there first', (
    tester,
  ) async {
    await startScenario(tester, shellScenario);
    await tapLabel(tester, 'push the inbox');
    await tapLabel(tester, 'Letter 1');
    await tapLabel(tester, 'Letter 2');
    expect(shownState(tester), 'HomeRoute() > [InboxRoute() > LetterRoute(2)]');

    await tapLabel(tester, 'System back');

    expect(shownState(tester), 'HomeRoute() > [InboxRoute()]');
  });

  testWidgets('go to a room from the profile switches tabs', (tester) async {
    await startScenario(tester, tabsScenario);
    await tapLabel(tester, 'Profile');

    await tapLabel(tester, 'go to room 5 (another tab)');

    expect(shownState(tester), startsWith('{*RoomsBranch: [RoomsRoute() > '));
    expect(find.text('Room 5'), findsOneWidget);
  });

  testWidgets('the page view follows the tab bar', (tester) async {
    await startScenario(tester, tabsPageViewScenario);

    await tapLabel(tester, 'Friends');

    expect(shownState(tester), contains('*FriendsBranch'));
    expect(find.text('Built on the first visit to this tab.'), findsOne);
  });

  testWidgets('a tab tapped while the page view moves wins', (tester) async {
    await startScenario(tester, tabsPageViewScenario);
    await tester.tap(find.text('Profile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tapLabel(tester, 'Friends');

    expect(shownState(tester), contains('*FriendsBranch'));
    expect(
      find.text('Built on the first visit to this tab.').hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('a page on the root slot covers the tab bar', (tester) async {
    await startScenario(tester, navigatorSlotsScenario);

    await tapLabel(tester, 'Create a room (root slot)');

    expect(find.byType(NavigationBar), findsNothing);
    await tapLabel(tester, 'System back');
    await tapLabel(tester, 'open room 1');
    await tapLabel(tester, 'Members (rooms branch slot)');
    expect(find.text('Room shell'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
