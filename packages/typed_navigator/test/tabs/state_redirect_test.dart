// The state with tabs, and their redirects.

import 'package:flutter_test/flutter_test.dart';

import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/tabs_fixtures.dart';

void main() {
  testWidgets('the state shows the active path and toString shows the '
      'branches', (tester) async {
    final router = await pumpTabsApp(tester, ann);

    await settled(tester, () => router.go(room7));

    final state = router.state;
    expect(state.routes, const [rooms, room7]);
    expect(state.top, room7);
    expect(state.find<FriendRoute>(), isNull);
    expect(
      state.toString(),
      '{*RoomsBranch: [RoomsRoute() > RoomRoute(RoomId(7))] | '
      'FriendsBranch: [FriendsRoute() > FriendRoute(ann)]}',
    );
    expect(find.text('Room 7'), findsOneWidget);
    expect(find.text('Friend ann'), findsNothing);
  });

  testWidgets('tab redirects guard the branches and run on a switch', (
    tester,
  ) async {
    var isFriendBlocked = false;
    final calls = <String>[];
    final router = await pumpTabsApp(
      tester,
      ann,
      redirect: (context, target) {
        calls.add('tabs: ${target.top}');
        return isFriendBlocked && target.top is FriendRoute
            ? const AccountRoute()
            : null;
      },
    );
    await settled(tester, () => router.go(rooms));
    expect(calls.last, 'tabs: RoomsRoute()');

    isFriendBlocked = true;
    router.refresh();
    expect(router.state.top, rooms);

    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());
    expect(router.state.toString(), 'AccountRoute()');
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Friend ann', skipOffstage: false), findsNothing);
  });
}
