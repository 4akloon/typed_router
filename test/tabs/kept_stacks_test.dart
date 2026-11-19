// The stacks of branches not on screen stay on the stack until something
// removes them.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/tabs_fixtures.dart';

void main() {
  testWidgets('re-tapping the active tab keeps its stack and removes the '
      'root routes above the tabs', (tester) async {
    final router = await pumpTabsApp(tester, room7);
    final room = ResultProbe(router.push(room8));
    await settled(tester, () => router.push(const AccountRoute()).ignore());

    await settled(tester, () => shellOf(tester).goBranch<RoomsBranch>());

    expect(
      router.state.toString(),
      '{*RoomsBranch: [RoomsRoute() > RoomRoute(RoomId(7)) > '
      'RoomRoute(RoomId(8))]}',
    );
    expect(room.isCompleted, isFalse);
    await settled(tester, () => shellOf(tester).goBranchAt(0));
    expect(router.state.top, room8);
  });

  testWidgets('dispose ends the pushes waiting in branches not on screen', (
    tester,
  ) async {
    final router = TypedRouter(
      routes: tabsRoutes(ScreenLog()),
      initialRoute: rooms,
      pageFactory: const TestPageFactory(),
    );
    await pumpWidgetsRouter(tester, router);
    final room = ResultProbe(router.push(room8));
    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());
    await tester.pumpWidget(const SizedBox());

    router.dispose();
    await tester.pump();

    expect(room.completions, [null]);
  });

  testWidgets('Navigator.pop in a branch not on screen removes the page and '
      'completes its push', (tester) async {
    final router = await pumpTabsApp(tester, friends);
    final bob = ResultProbe(router.push(const FriendRoute('bob')));
    await tester.pumpAndSettle();
    final friendsNavigator = Navigator.of(
      tester.element(find.text('Friend bob')),
    );
    await settled(tester, () => shellOf(tester).goBranch<RoomsBranch>());

    friendsNavigator.pop('late');
    await tester.pumpAndSettle();

    expect(bob.completions, ['late']);
    expect(
      router.state.toString(),
      '{*RoomsBranch: [RoomsRoute()] | FriendsBranch: [FriendsRoute()]}',
    );
    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Friend bob', skipOffstage: false), findsNothing);
  });
}
