// Go, push, pop and back with tabs.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_test/typed_navigator_test.dart';

import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/tabs_fixtures.dart';

void main() {
  testWidgets('go to a route of another branch switches to it and keeps the '
      'others', (tester) async {
    final router = await pumpTabsApp(tester, room7);

    await settled(tester, () => router.go(ann));
    expect(
      router.state.toString(),
      '{RoomsBranch: [RoomsRoute() > RoomRoute(RoomId(7))] | '
      '*FriendsBranch: [FriendsRoute() > FriendRoute(ann)]}',
    );
    expect(find.text('Friend ann'), findsOneWidget);

    await settled(tester, () => router.go(room8));
    expect(
      router.state.toString(),
      '{*RoomsBranch: [RoomsRoute() > RoomRoute(RoomId(8))] | '
      'FriendsBranch: [FriendsRoute() > FriendRoute(ann)]}',
    );
  });

  testWidgets('push goes into the active branch, a route of another branch '
      'too, as go_router', (tester) async {
    final router = await pumpTabsApp(tester, rooms);

    await settled(tester, () => router.push(room7).ignore());
    expect(
      router.state.toString(),
      '{*RoomsBranch: [RoomsRoute() > RoomRoute(RoomId(7))]}',
    );

    await settled(tester, () => router.push(ann).ignore());
    expect(
      router.state.toString(),
      '{*RoomsBranch: [RoomsRoute() > RoomRoute(RoomId(7)) > '
      'FriendRoute(ann)]}',
    );
    expect(find.text('Friend ann'), findsOneWidget);
    expect(find.text('Tab 0'), findsOneWidget);
    expect(find.byType(StatefulShell), findsOneWidget);

    await settled(tester, router.pop);
    expect(find.text('Room 7'), findsOneWidget);
  });

  testWidgets('pop and back work in the active branch only', (tester) async {
    final router = await pumpTabsApp(tester, ann);
    await settled(tester, () => router.go(room7));
    await settled(tester, () => router.push(room8).ignore());

    await tester.systemBack();
    await settled(tester, router.pop<void>);

    expect(
      router.state.toString(),
      '{*RoomsBranch: [RoomsRoute()] | '
      'FriendsBranch: [FriendsRoute() > FriendRoute(ann)]}',
    );
    expect(find.text('Rooms'), findsOneWidget);
  });

  testWidgets('a route of another tab pushed into the active tab goes through '
      'its redirects', (tester) async {
    final router = await pumpTabsApp(
      tester,
      rooms,
      redirect: (context, target) =>
          target.top is FriendRoute ? const AccountRoute() : null,
    );

    await settled(tester, () => router.push(ann).ignore());

    expect(router.state.top, const AccountRoute());
    expect(find.text('Account'), findsOneWidget);
  });
}
