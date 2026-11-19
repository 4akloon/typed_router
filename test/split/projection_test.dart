// One stack, two projections.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/split_fixtures.dart';

void main() {
  testWidgets('a narrow split is one navigator and back reveals the real '
      'page below', (tester) async {
    final router = await pumpSplitApp(tester, room1, width: 400);

    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
    expect(find.text('Room 1:0'), findsOneWidget);
    expect(find.text('Rooms:0'), findsNothing);
    expect(navigatorOf(tester, 'Room 1').widget.pages, hasLength(2));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.state.toString(), '[RoomsRoute()]');
    expect(find.text('Rooms:0'), findsOneWidget);
  });

  testWidgets('a wide split shows two pages side by side with the same '
      'state', (tester) async {
    final router = await pumpSplitApp(tester, room1);

    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
    expect(rectOf(tester, 'Rooms:').left, 0);
    expect(rectOf(tester, 'Room 1:').left, 500);
    expect(find.text('Pick a room'), findsNothing);
  });

  testWidgets('crossing the width threshold both ways recreates no '
      'screen', (tester) async {
    final log = ScreenLog();
    await pumpSplitApp(tester, room1, log: log, width: 400);
    await tapScreen(tester, 'Room 1');

    await resizeWindow(tester, 1000);
    await tapScreen(tester, 'Rooms');
    expect(find.text('Room 1:1'), findsOneWidget);

    await resizeWindow(tester, 400);
    expect(find.text('Room 1:1'), findsOneWidget);
    await resizeWindow(tester, 1000);
    expect(find.text('Rooms:1'), findsOneWidget);
    expect(log.created, ['Rooms', 'Room 1']);
  });

  testWidgets('three columns of four pages keep the first alive offstage '
      'until pop', (tester) async {
    final log = ScreenLog();
    final router = await pumpSplitApp(tester, playerAnn, log: log, columns: 3);
    await tapScreen(tester, 'Rooms');
    router.push(playerBob).ignore();
    await tester.pumpAndSettle();

    expect(find.textContaining('Rooms:'), findsNothing);
    expect(find.text('Rooms:1', skipOffstage: false), findsOneWidget);
    expect(rectOf(tester, 'Room 1:').left, 0);
    expect(rectOf(tester, 'Player bob:').left, closeTo(666.7, 0.1));

    router.pop<String>();
    await tester.pumpAndSettle();

    expect(find.text('Rooms:1'), findsOneWidget);
    expect(log.created, ['Rooms', 'Room 1', 'Player ann', 'Player bob']);
  });

  testWidgets('maximumColumns receives the size of the split, not of the '
      'window', (tester) async {
    setWindowWidth(tester, 1000);
    final sizes = <Size>[];
    final router = TypedRouter(
      routes: [
        ShellNode<NoParentRoute>(
          builder: (context, state, navigator) => Row(
            children: [
              const SizedBox(width: 200),
              Expanded(child: navigator),
            ],
          ),
          children: [
            SplitNode<NoParentRoute>(
              maximumColumns: (size) {
                sizes.add(size);
                return 2;
              },
              children: [
                RouteNode<RoomsRoute>(build: (context, _) => const Text('R')),
              ],
            ),
          ],
        ),
      ],
      initialRoute: rooms,
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);

    expect(sizes.last, const Size(800, 600));
  });
}
