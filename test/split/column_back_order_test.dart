// The app's own local history goes first, an app PopScope hears the pop, and
// the button follows a column through a window shift and under a cover.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/column_back_fixtures.dart';
import '../support/split_fixtures.dart';

const _player = PlayerRoute(1, 'ann');
const _all = '[RoomsRoute() > RoomRoute(RoomId(1)) > PlayerRoute(1, ann)]';

void main() {
  testWidgets("the app's local history in a column that becomes a middle "
      'one closes first', (tester) async {
    final router = await pumpColumns(tester, columnBackRoutes([]), room1);
    var isAppEntryRemoved = false;
    ModalRoute.of(tester.element(find.text('Room 1')))?.addLocalHistoryEntry(
      LocalHistoryEntry(onRemove: () => isAppEntryRemoved = true),
    );
    await tester.pumpAndSettle();
    router.push(_player).ignore();
    await tester.pumpAndSettle();

    await navigatorTitled(tester, 'Room 1').maybePop();
    await tester.pumpAndSettle();
    expect(isAppEntryRemoved, isTrue);
    expect(router.state.toString(), _all);

    await tester.tap(backButtonOf('Room 1'));
    await tester.pumpAndSettle();
    expect(router.state.toString(), '[RoomsRoute()]');
  });

  testWidgets('an app PopScope in a middle column hears its back button '
      'pop it', (tester) async {
    final attempts = <bool>[];
    final router = await pumpColumns(
      tester,
      columnBackRoutes(attempts),
      const PlayerRoute(8, 'ann'),
    );

    await tester.tap(backButtonOf('Room 8'));
    await tester.pumpAndSettle();

    expect(attempts, [true]);
    expect(router.state.toString(), '[RoomsRoute()]');
  });

  testWidgets('a page on screen to the right that refuses keeps the middle '
      'column open and hears it', (tester) async {
    final attempts = <bool>[];
    final router = await pumpColumns(
      tester,
      columnBackRoutes(attempts),
      const PlayerRoute(1, 'eve'),
    );
    const before =
        '[RoomsRoute() > RoomRoute(RoomId(1)) > PlayerRoute(1, eve)]';

    await tester.tap(backButtonOf('Room 1'));
    await tester.pumpAndSettle();
    expect(attempts, [false]);
    expect(router.state.toString(), before);

    navigatorTitled(tester, 'Room 1').pop();
    await tester.pumpAndSettle();
    expect(attempts, [false, false]);
    expect(router.state.toString(), before);
    expect(backButtonOf('Room 1'), findsOneWidget);
  });

  testWidgets('a middle column that leaves the window and comes back keeps '
      'its back button and closes nothing', (tester) async {
    final router = await pumpColumns(
      tester,
      columnBackRoutes([]),
      const RoomsRoute(),
    );
    router.push(room1).ignore();
    await tester.pumpAndSettle();
    router.push(_player).ignore();
    await tester.pumpAndSettle();
    router.push(const PlayerRoute(1, 'bob')).ignore();
    await tester.pumpAndSettle();
    expect(find.text('Rooms'), findsNothing);

    router.pop();
    await tester.pumpAndSettle();

    expect(router.state.toString(), _all);
    expect(backButtonOf('Room 1'), findsOneWidget);
    expect(backButtonOf('Rooms'), findsNothing);
  });
}
