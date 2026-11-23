// Tabs, their branches and switching.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/tabs_fixtures.dart';

void main() {
  testWidgets('tabs show the navigator of the active branch', (tester) async {
    final router = await pumpTabsApp(tester, rooms);

    final shell = shellOf(tester);
    expect(shell.currentIndex, 0);
    expect(shell.activeBranch, RoomsBranch);
    expect(find.text('Rooms'), findsOneWidget);
    expect(find.text('Tab 0'), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.text('Rooms'))),
      isNot(same(router.navigator)),
    );
  });

  testWidgets('the first visit to a branch shows its initial chain', (
    tester,
  ) async {
    final router = await pumpTabsApp(tester, rooms);
    expect(find.text('Friends', skipOffstage: false), findsNothing);

    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());

    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Tab 1'), findsOneWidget);
    expect(
      router.state.toString(),
      '{RoomsBranch: [RoomsRoute()] | *FriendsBranch: [FriendsRoute()]}',
    );
  });

  testWidgets('coming back to a branch shows its kept stack', (tester) async {
    final log = ScreenLog();
    final router = await pumpTabsApp(tester, room7, log: log);
    final room = ResultProbe(router.push(room8));
    await tester.pumpAndSettle();

    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());
    await settled(tester, () => shellOf(tester).goBranch<RoomsBranch>());

    expect(router.state.routes, const [rooms, room7, room8]);
    expect(find.text('Room 8'), findsOneWidget);
    expect(log.created.where((text) => text == 'Room 8'), hasLength(1));
    expect(room.isCompleted, isFalse);
  });

  testWidgets('goBranchAt switches by index', (tester) async {
    final router = await pumpTabsApp(tester, rooms);

    await settled(tester, () => shellOf(tester).goBranchAt(1));
    expect(router.state.top, friends);
    expect(find.text('Friends'), findsOneWidget);

    await settled(tester, () => shellOf(tester).goBranchAt(0));
    expect(router.state.top, rooms);
    expect(find.text('Rooms'), findsOneWidget);
  });

  testWidgets('resetBranch returns the branch to its initial route', (
    tester,
  ) async {
    final router = await pumpTabsApp(tester, room7);
    final room = ResultProbe(router.push(room8));
    await tester.pumpAndSettle();

    await settled(tester, () => shellOf(tester).resetBranch<RoomsBranch>());
    expect(router.state.routes, const [rooms]);
    expect(room.completions, [null]);
    expect(find.text('Rooms'), findsOneWidget);
    expect(find.text('Room 8', skipOffstage: false), findsNothing);

    await settled(tester, () => router.go(ann));
    await settled(tester, () => shellOf(tester).resetBranchAt(1));
    expect(router.state.routes, const [friends]);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Friend ann', skipOffstage: false), findsNothing);
  });

  testWidgets('goBranch removes the root routes above the tabs', (
    tester,
  ) async {
    final router = await pumpTabsApp(tester, rooms);
    await settled(tester, () => router.push(const AccountRoute()).ignore());
    expect(
      router.state.toString(),
      '{*RoomsBranch: [RoomsRoute()]} > AccountRoute()',
    );

    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());

    expect(
      router.state.toString(),
      '{RoomsBranch: [RoomsRoute()] | *FriendsBranch: [FriendsRoute()]}',
    );
    expect(find.text('Account', skipOffstage: false), findsNothing);
  });
}
