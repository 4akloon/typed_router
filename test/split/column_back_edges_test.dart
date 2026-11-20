// The back button of middle columns leaves gestures to the deepest column,
// follows the column's place, and leaves pageless routes and stacks alone.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/testing.dart';

import '../support/column_back_fixtures.dart';
import '../support/operation_fixtures.dart' show ResultProbe;
import '../support/split_fixtures.dart';

const _player = PlayerRoute(1, 'ann');
const _deepestClosed = '[RoomsRoute() > RoomRoute(RoomId(1))]';
const _all = '[RoomsRoute() > RoomRoute(RoomId(1)) > PlayerRoute(1, ann)]';

void main() {
  testWidgets('predictive back still closes only the deepest column', (
    tester,
  ) async {
    final router = await pumpColumns(tester, columnBackRoutes([]), _player);

    await tester.predictiveBack();

    expect(router.state.toString(), _deepestClosed);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('an iOS swipe from the edge of a middle column closes nothing', (
    tester,
  ) async {
    final router = await pumpColumns(tester, columnBackRoutes([]), _player);
    final edge = tester.getTopLeft(find.text('Room 1')).dx;

    await tester.dragFrom(Offset(edge - 10, 500), const Offset(300, 0));
    await tester.pumpAndSettle();

    expect(router.state.toString(), _all);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('a column that becomes the deepest or stops being it closes '
      'nothing', (tester) async {
    final router = await pumpColumns(tester, columnBackRoutes([]), _player);
    expect(popsInternally(tester, 'Room 1'), isTrue);

    router.pop();
    await tester.pumpAndSettle();
    expect(router.state.toString(), _deepestClosed);
    expect(popsInternally(tester, 'Room 1'), isFalse);

    router.push(_player).ignore();
    await tester.pumpAndSettle();
    expect(router.state.toString(), _all);
    expect(popsInternally(tester, 'Room 1'), isTrue);
  });

  testWidgets('a pageless route in a middle column closes with its own back '
      'button', (tester) async {
    final router = await pumpColumns(tester, columnBackRoutes([]), _player);
    final sheet = ResultProbe(
      navigatorTitled(tester, 'Room 1').push(
        MaterialPageRoute<String>(
          builder: (context) =>
              Scaffold(appBar: AppBar(title: const Text('Sheet'))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(backButtonOf('Sheet'));
    await tester.pumpAndSettle();

    expect(sheet.completions, [null]);
    expect(router.state.toString(), _all);
  });

  testWidgets('switching to a stack and back leaves no extra back button and '
      'closes nothing', (tester) async {
    final router = await pumpColumns(tester, columnBackRoutes([]), _player);

    await resizeWindow(tester, 400);
    expect(popsInternally(tester, 'Room 1'), isFalse);
    await resizeWindow(tester, 1200);

    expect(router.state.toString(), _all);
    expect(popsInternally(tester, 'Room 1'), isTrue);
    expect(backButtonOf('Rooms'), findsNothing);
  });
}
