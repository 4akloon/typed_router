// Navigators of columns at the edges
// (stale pops, pageless routes, maybePop, results, dialogs).

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/operation_fixtures.dart';
import '../support/split_fixtures.dart';

PageRouteBuilder<String> _sheet(String text) => PageRouteBuilder<String>(
  opaque: false,
  pageBuilder: (context, _, _) => Text(text),
);

void main() {
  testWidgets('a column that pops a page already gone from the state '
      'changes nothing', (tester) async {
    final router = await pumpSplitApp(tester, playerAnn, columns: 3);
    final player = navigatorOf(tester, 'Player ann');

    router.go(room2);
    player.pop();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(2))]');
  });

  testWidgets('a pageless route of a column that leaves completes with '
      'null', (tester) async {
    final router = await pumpSplitApp(tester, room1);
    final sheet = ResultProbe(navigatorOf(tester, 'Room 1').push(_sheet('S')));
    await tester.pumpAndSettle();

    router.go(room2);
    await tester.pumpAndSettle();

    expect(sheet.completions, [null]);
  });

  testWidgets('every column but the first can pop, so it shows back', (
    tester,
  ) async {
    await pumpSplitApp(tester, playerAnn, columns: 3);

    expect(navigatorOf(tester, 'Rooms').canPop(), isFalse);
    expect(navigatorOf(tester, 'Room 1').canPop(), isTrue);
    expect(navigatorOf(tester, 'Player ann').canPop(), isTrue);
    expect(
      ModalRoute.of(
        tester.element(find.text('Room 1:0')),
      )?.impliesAppBarDismissal,
      isTrue,
    );
  });

  testWidgets('maybePop in the deepest column closes it', (tester) async {
    final router = await pumpSplitApp(tester, playerAnn, columns: 3);

    await navigatorOf(tester, 'Player ann').maybePop();
    await tester.pumpAndSettle();

    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
  });

  testWidgets('Navigator.pop in a column delivers its result', (tester) async {
    final router = await pumpSplitApp(tester, room1, columns: 3);
    final verdict = router.push(playerAnn);
    await tester.pumpAndSettle();

    navigatorOf(tester, 'Player ann').pop('guilty');
    await tester.pumpAndSettle();

    expect(await verdict, 'guilty');
  });

  testWidgets('showGeneralDialog from a column opens on the root', (
    tester,
  ) async {
    final router = await pumpSplitApp(tester, room1);

    showGeneralDialog<void>(
      context: tester.element(find.text('Room 1:0')),
      pageBuilder: (context, _, _) => const Text('Dialog'),
    ).ignore();
    await tester.pumpAndSettle();

    expect(
      Navigator.of(tester.element(find.text('Dialog'))),
      same(router.navigator),
    );
  });
}
