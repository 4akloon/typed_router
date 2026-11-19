// Pages over the split, over the app, and pageless routes from a column.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/split_fixtures.dart';

void main() {
  testWidgets('a cover route spans the split over the columns and back '
      'reveals them unchanged', (tester) async {
    final log = ScreenLog();
    final router = await pumpSplitApp(tester, room1, log: log);
    await tapScreen(tester, 'Rooms');
    await tapScreen(tester, 'Room 1');

    router.push(lobby).ignore();
    await tester.pumpAndSettle();

    expect(rectOf(tester, 'Lobby:').left, 0);
    expect(find.textContaining('Rooms:'), findsNothing);
    expect(find.text('Rooms:1', skipOffstage: false), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
    expect(find.text('Rooms:1'), findsOneWidget);
    expect(find.text('Room 1:1'), findsOneWidget);
    expect(log.created, ['Rooms', 'Room 1', 'Lobby']);
  });

  testWidgets('a route on the root slot covers the whole app with the '
      'split', (tester) async {
    final router = await pumpSplitApp(tester, room1);

    router.push(const RulesRoute()).ignore();
    await tester.pumpAndSettle();

    expect(
      router.state.toString(),
      '[RoomsRoute() > RoomRoute(RoomId(1))] > RulesRoute()',
    );
    expect(router.navigator?.widget.pages, hasLength(2));
    expect(find.text('Rules'), findsOneWidget);
    expect(find.textContaining('Room 1:'), findsNothing);
  });

  testWidgets('a pageless route from a column opens in its navigator, a '
      'dialog on the root', (tester) async {
    final router = await pumpSplitApp(tester, room1);
    final roomsNavigator = navigatorOf(tester, 'Rooms');

    roomsNavigator.push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (context, _, _) => const Text('Sheet of rooms'),
      ),
    );
    Navigator.of(
      tester.element(find.text('Room 1:0')),
      rootNavigator: true,
    ).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (context, _, _) => const Text('Dialog'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      Navigator.of(tester.element(find.text('Sheet of rooms'))),
      same(roomsNavigator),
    );
    expect(
      Navigator.of(tester.element(find.text('Dialog'))),
      same(router.navigator),
    );
    expect(roomsNavigator, isNot(same(navigatorOf(tester, 'Room 1'))));
  });
}
