// Pageless routes inside a level in a column, in a column the window hides,
// under a cover, and a split in a hidden branch.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/column_back_fixtures.dart';
import '../support/operation_fixtures.dart' show ResultProbe;
import '../support/split_fixtures.dart';
import '../support/tabs_fixtures.dart' show RoomsBranch, friends, friendsBranch;

MaterialPageRoute<String> _sheet() =>
    MaterialPageRoute<String>(builder: (context) => const Text('Sheet'));

void main() {
  testWidgets('back closes a sheet inside a shell in a middle column first', (
    tester,
  ) async {
    final router = await pumpColumns(
      tester,
      shellColumnRoutes(),
      const PlayerRoute(1, 'ann'),
    );
    final before = router.state.toString();
    final sheet = ResultProbe(navigatorTitled(tester, 'Room 1').push(_sheet()));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(sheet.completions, [null]);
    expect(router.state.toString(), before);
  });

  testWidgets('Navigator.pop with a result in the deepest column while a '
      'sheet lies to its left completes the push with null', (tester) async {
    final router = await pumpColumns(tester, columnBackRoutes([]), room1);
    final verdict = ResultProbe(router.push(const PlayerRoute(1, 'ann')));
    await tester.pumpAndSettle();
    navigatorTitled(tester, 'Room 1').push(_sheet()).ignore();
    await tester.pumpAndSettle();

    navigatorTitled(tester, 'Player ann').pop('guilty');
    await tester.pumpAndSettle();

    expect(verdict.completions, [null]);
    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
  });

  testWidgets('a sheet in a column the window hides does not take back', (
    tester,
  ) async {
    final router = await pumpSplitApp(tester, room1);
    final sheet = ResultProbe(navigatorOf(tester, 'Rooms').push(_sheet()));
    await tester.pumpAndSettle();
    router.go(playerAnn);
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(sheet.completions, isEmpty);
    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
  });

  testWidgets('a cover without pageless routes does not delay a change of '
      'projection', (tester) async {
    await pumpSplitApp(tester, lobby);

    setWindowWidth(tester, 400);
    await tester.pump();

    expect(navigatorOf(tester, 'Room 1'), same(navigatorOf(tester, 'Lobby')));
  });

  testWidgets('two covers without pageless routes do not delay a change of '
      'projection', (tester) async {
    final router = await pumpSplitApp(tester, lobby);
    router.push(room2).ignore();
    await tester.pumpAndSettle();

    setWindowWidth(tester, 400);
    await tester.pump();

    expect(navigatorOf(tester, 'Rooms'), same(navigatorOf(tester, 'Room 2')));
  });

  testWidgets('a split in a hidden branch survives a resize', (tester) async {
    setWindowWidth(tester, 1000);
    final router = TypedRouter(
      routes: [
        StatefulShellNode(
          builder: (context, state, shell) => shell,
          branches: [
            BranchNode<RoomsBranch>(
              initial: rooms,
              children: [roomsSplit(ScreenLog())],
            ),
            friendsBranch(ScreenLog()),
          ],
        ),
      ],
      initialRoute: room1,
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);
    await tester.pumpAndSettle();
    router.go(friends);
    await tester.pumpAndSettle();

    await resizeWindow(tester, 400);

    expect(tester.takeException(), isNull);
  });
}
