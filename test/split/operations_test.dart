// Router operations on a split.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/split_fixtures.dart';

void main() {
  testWidgets('go to a sibling replaces the column and completes the pushes '
      'of deeper ones with null', (tester) async {
    final router = await pumpSplitApp(tester, room1, columns: 3);
    final verdict = router.push(playerAnn);
    await tester.pumpAndSettle();

    router.go(room2);
    await tester.pumpAndSettle();

    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(2))]');
    expect(await verdict, isNull);
    expect(find.textContaining('Player ann:'), findsNothing);
    expect(rectOf(tester, 'Room 2:').left, closeTo(333.3, 0.1));
  });

  testWidgets('push adds the deepest column and back removes it', (
    tester,
  ) async {
    final router = await pumpSplitApp(tester, room1);

    router.push(room2).ignore();
    await tester.pumpAndSettle();
    expect(rectOf(tester, 'Room 1:').left, 0);
    expect(rectOf(tester, 'Room 2:').left, 500);
    expect(find.textContaining('Rooms:'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
    expect(rectOf(tester, 'Rooms:').left, 0);
    expect(rectOf(tester, 'Room 1:').left, 500);
  });

  testWidgets('the window shifts instantly on push and pop and recreates no '
      'screen', (tester) async {
    final log = ScreenLog();
    final router = await pumpSplitApp(tester, room1, log: log);
    Navigator.of(tester.element(find.text('Room 1:0'))).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (context, _, _) => const Text('Sheet of room 1'),
      ),
    );
    await tester.pumpAndSettle();

    router.push(room2).ignore();
    await tester.pump();
    expect(rectOf(tester, 'Room 1:').left, 0);
    expect(rectOf(tester, 'Room 2:').left, 500);
    expect(find.text('Sheet of room 1'), findsOneWidget);

    router.pop<void>();
    await tester.pump();
    expect(rectOf(tester, 'Rooms:').left, 0);
    expect(find.textContaining('Room 2:'), findsNothing);
    expect(log.created, ['Rooms', 'Room 1', 'Room 2']);
  });

  testWidgets('a deep link into the detail shows list and detail when wide '
      'and a stack when narrow', (tester) async {
    await pumpSplitApp(tester, room1);
    expect(find.text('Rooms:0'), findsOneWidget);
    expect(find.text('Room 1:0'), findsOneWidget);

    await pumpSplitApp(tester, room1, width: 400);
    expect(find.text('Rooms:0'), findsNothing);
    expect(find.text('Room 1:0'), findsOneWidget);
  });

  testWidgets('push of a detail from outside the split opens a split with '
      'the detail alone', (tester) async {
    final router = await pumpSplitApp(tester, const AccountRoute());

    router.push(room1).ignore();
    await tester.pumpAndSettle();
    expect(find.textContaining('Rooms:'), findsNothing);
    expect(rectOf(tester, 'Room 1:').left, 0);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.state.toString(), 'AccountRoute()');
    expect(find.text('Account'), findsOneWidget);
  });
}
