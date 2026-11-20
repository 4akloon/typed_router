// Columns other than the deepest and the first show a back button that closes
// them and the columns to their right.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/column_back_fixtures.dart';
import '../support/operation_fixtures.dart' show ResultProbe;
import '../support/split_fixtures.dart';

const _player = PlayerRoute(1, 'ann');

void main() {
  testWidgets('middle columns show a back button and the first column does '
      'not', (tester) async {
    await pumpColumns(tester, columnBackRoutes([]), _player);

    expect(backButtonOf('Rooms'), findsNothing);
    expect(backButtonOf('Room 1'), findsOneWidget);
    expect(backButtonOf('Player ann'), findsOneWidget);
    expect(navigatorTitled(tester, 'Room 1').canPop(), isTrue);
  });

  testWidgets('a shell in a middle column closes with maybePop from its '
      'frame, and its first page shows no back button', (tester) async {
    final router = await pumpColumns(tester, shellColumnRoutes(), _player);
    expect(
      router.state.toString(),
      '[RoomsRoute() > [RoomRoute(RoomId(1))] > PlayerRoute(1, ann)]',
    );
    expect(backButtonOf('Room 1'), findsNothing);

    await Navigator.maybePop(tester.element(find.text('Shell frame')));
    await tester.pumpAndSettle();

    expect(router.state.toString(), '[RoomsRoute()]');
  });

  testWidgets('the back button of a middle column closes it and the columns '
      'to its right', (tester) async {
    final router = await pumpColumns(tester, columnBackRoutes([]), room1);
    final verdict = ResultProbe(router.push(_player));
    await tester.pumpAndSettle();

    await tester.tap(backButtonOf('Room 1'));
    await tester.pumpAndSettle();

    expect(router.state.toString(), '[RoomsRoute()]');
    expect(verdict.completions, [null]);
    expect(find.text('Rooms'), findsOneWidget);
  });

  testWidgets('an app PopScope in a middle column blocks its back button', (
    tester,
  ) async {
    final attempts = <bool>[];
    final router = await pumpColumns(
      tester,
      columnBackRoutes(attempts),
      const PlayerRoute(9, 'bob'),
    );

    await tester.tap(backButtonOf('Room 9'));
    await tester.pumpAndSettle();

    expect(attempts, [false]);
    expect(
      router.state.toString(),
      '[RoomsRoute() > RoomRoute(RoomId(9)) > PlayerRoute(9, bob)]',
    );
  });

  testWidgets('Navigator.pop with a result in a middle column completes its '
      'push with null', (tester) async {
    final router = await pumpColumns(
      tester,
      columnBackRoutes([]),
      const RoomsRoute(),
    );
    final room = ResultProbe(router.push(room1));
    await tester.pumpAndSettle();
    router.push(_player).ignore();
    await tester.pumpAndSettle();

    navigatorTitled(tester, 'Room 1').pop('kept');
    await tester.pumpAndSettle();

    expect(router.state.toString(), '[RoomsRoute()]');
    expect(room.completions, [null]);
  });
}
