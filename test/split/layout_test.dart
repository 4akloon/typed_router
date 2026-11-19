// A custom layout, navigators of columns and semantics.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/split_fixtures.dart';

void main() {
  testWidgets('a custom builder receives typed columns in order', (
    tester,
  ) async {
    final seen = <String>[];
    final router = await pumpSplitApp(
      tester,
      rooms,
      builder: (context, state, split) {
        seen
          ..clear()
          ..addAll([
            for (final column in split.columns)
              switch (column) {
                RouteColumn(:final route) => 'route $route',
                PlaceholderColumn(:final route) => 'placeholder $route',
              },
          ]);
        return Row(
          children: [
            for (final column in split.columns) Expanded(child: column.child),
          ],
        );
      },
    );
    expect(seen, ['route RoomsRoute()', 'placeholder RoomsRoute()']);

    router.go(room1);
    await tester.pumpAndSettle();
    expect(seen, ['route RoomsRoute()', 'route RoomRoute(RoomId(1))']);

    await resizeWindow(tester, 400);
    expect(seen, ['route RoomRoute(RoomId(1))']);
  });

  testWidgets('Navigator.pop in a column pops its route and every deeper '
      'one, completing their pushes with null', (tester) async {
    final router = await pumpSplitApp(tester, room1, columns: 3);
    final verdict = router.push(playerAnn);
    await tester.pumpAndSettle();
    await tapScreen(tester, 'Rooms');
    expect(navigatorOf(tester, 'Rooms').canPop(), isFalse);

    navigatorOf(tester, 'Room 1').pop();
    await tester.pumpAndSettle();

    expect(router.state.toString(), '[RoomsRoute()]');
    expect(await verdict, isNull);
    expect(find.text('Rooms:1'), findsOneWidget);
    expect(find.text('Pick a room'), findsOneWidget);
  });

  testWidgets('Navigator.pop in the deepest column pops its route only', (
    tester,
  ) async {
    final router = await pumpSplitApp(tester, playerAnn, columns: 3);

    navigatorOf(tester, 'Player ann').pop('kept');
    await tester.pumpAndSettle();

    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
  });

  testWidgets('each column is its own semantics node', (tester) async {
    final semantics = tester.ensureSemantics();
    final router = await pumpSplitApp(tester, room1, columns: 3);
    router.push(playerAnn).ignore();
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Rooms:0'), findsOneWidget);
    expect(find.bySemanticsLabel('Room 1:0'), findsOneWidget);
    expect(find.bySemanticsLabel('Player ann:0'), findsOneWidget);
    semantics.dispose();
  });
}
