// Go keeps what it can of the tabs: their instance anywhere on the active path,
// the common prefix of a kept branch stack, the stacks of nested tabs.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/nested_tabs_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/tabs_fixtures.dart';

void main() {
  testWidgets('go to a route of another branch keeps the common prefix of '
      'its kept stack', (tester) async {
    final log = ScreenLog();
    final router = await pumpTabsApp(tester, room7, log: log);
    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());

    await settled(tester, () => router.go(room8));

    expect(router.state.routes, const [rooms, room8]);
    expect(log.created.where((text) => text == 'Rooms'), hasLength(1));
  });

  testWidgets('go reuses the tabs wherever they stand on the active path', (
    tester,
  ) async {
    final router = await pumpTabsApp(tester, const AccountRoute());
    await settled(tester, () => router.push(room7).ignore());
    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());

    await settled(tester, () => router.go(const FriendRoute('bob')));

    expect(
      router.state.toString(),
      '{RoomsBranch: [RoomRoute(RoomId(7))] | '
      '*FriendsBranch: [FriendsRoute() > FriendRoute(bob)]}',
    );
  });

  testWidgets('nested tabs keep their stacks when the outer tabs switch', (
    tester,
  ) async {
    final router = TypedRouter(
      routes: nestedTabsRoutes(ScreenLog()),
      initialRoute: rooms,
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);
    final room = ResultProbe(router.push(room7));
    await tester.pumpAndSettle();

    await settled(
      tester,
      () => shellWith(tester, FriendsBranch).goBranchAt(1),
    );
    await settled(tester, () => shellWith(tester, OuterAccount).goBranchAt(1));
    await settled(tester, () => shellWith(tester, OuterAccount).goBranchAt(0));
    await settled(
      tester,
      () => shellWith(tester, FriendsBranch).goBranchAt(0),
    );

    expect(router.state.routes, const [rooms, room7]);
    expect(room.isCompleted, isFalse);
    expect(find.text('Room 7'), findsOneWidget);
  });
}
