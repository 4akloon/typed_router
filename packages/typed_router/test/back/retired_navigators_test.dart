// A pageless route in a nested navigator that leaves the state completes with
// null instead of hanging.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/shell_fixtures.dart';
import '../support/tabs_fixtures.dart';

/// Opens a pageless route in the navigator of the page showing [text].
Future<ResultProbe<String>> _openPageless(
  WidgetTester tester,
  String text,
) async {
  final probe = ResultProbe(
    Navigator.of(tester.element(find.text(text))).push(
      PageRouteBuilder<String>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            Text('Pageless over $text'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return probe;
}

void main() {
  testWidgets('go that removes a shell completes a pageless route in it with '
      'null', (tester) async {
    final router = await pumpShellApp(tester, user1);
    final pageless = await _openPageless(tester, 'User u1');

    await settleAfter(tester, () => router.go(account));

    expect(pageless.completions, [null]);
    expect(router.state.toString(), 'AccountRoute()');
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Pageless over User u1'), findsNothing);
  });

  testWidgets('go that removes tabs completes pageless routes in every branch '
      'with null', (tester) async {
    final router = await pumpTabsApp(tester, friends);
    final inFriends = await _openPageless(tester, 'Friends');
    await settled(tester, () => shellOf(tester).goBranch<RoomsBranch>());
    final inRooms = await _openPageless(tester, 'Rooms');

    await settled(tester, () => router.go(const AccountRoute()));

    expect(inRooms.completions, [null]);
    expect(inFriends.completions, [null]);
    expect(find.text('Account'), findsOneWidget);
    expect(find.textContaining('Pageless', skipOffstage: false), findsNothing);
  });

  testWidgets('switching branches keeps a pageless route of the branch it '
      'leaves', (tester) async {
    await pumpTabsApp(tester, friends);
    final inFriends = await _openPageless(tester, 'Friends');

    await settled(tester, () => shellOf(tester).goBranch<RoomsBranch>());
    expect(inFriends.isCompleted, isFalse);

    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());
    expect(inFriends.isCompleted, isFalse);
    expect(find.text('Pageless over Friends'), findsOneWidget);
  });

  testWidgets('a page leaving a branch not on screen keeps the pageless '
      'routes of its navigator', (tester) async {
    final router = await pumpTabsApp(tester, friends);
    final overFriends = await _openPageless(tester, 'Friends');
    await settled(tester, () => router.push(ann).ignore());
    final friendsNavigator = Navigator.of(
      tester.element(find.text('Friend ann')),
    );
    await settled(tester, () => shellOf(tester).goBranch<RoomsBranch>());

    friendsNavigator.pop();
    await tester.pumpAndSettle();

    expect(overFriends.isCompleted, isFalse);
    expect(
      router.state.toString(),
      '{*RoomsBranch: [RoomsRoute()] | FriendsBranch: [FriendsRoute()]}',
    );
    expect(find.text('Rooms'), findsOneWidget);
    expect(
      find.text('Pageless over Friends', skipOffstage: false),
      findsOneWidget,
    );
  });
}
