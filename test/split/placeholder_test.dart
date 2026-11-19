// The placeholder of the top route.

import 'package:flutter_test/flutter_test.dart';

import '../support/split_fixtures.dart';

void main() {
  testWidgets('a top route with a placeholder shows it as the next column; '
      'without one it fills the split', (tester) async {
    final router = await pumpSplitApp(tester, rooms, columns: 3);

    expect(rectOf(tester, 'Rooms:').left, 0);
    expect(rectOf(tester, 'Pick a room').left, closeTo(333.3, 0.1));

    router.go(room1);
    await tester.pumpAndSettle();

    expect(find.text('Pick a room'), findsNothing);
    expect(rectOf(tester, 'Room 1:').left, closeTo(333.3, 0.1));
    expect(
      tester.getSize(find.byType(CountingScreen).last).width,
      closeTo(666.7, 0.1),
    );
  });

  testWidgets('a single route without a placeholder takes the whole '
      'split', (tester) async {
    final router = await pumpSplitApp(tester, const AccountRoute());

    router.push(room1).ignore();
    await tester.pumpAndSettle();

    expect(router.state.toString(), 'AccountRoute() > [RoomRoute(RoomId(1))]');
    expect(tester.getSize(find.byType(CountingScreen)).width, 1000);
  });

  testWidgets('selecting an item replaces the placeholder and back brings '
      'it back', (tester) async {
    final router = await pumpSplitApp(tester, rooms);
    await tapScreen(tester, 'Rooms');

    router.go(room1);
    await tester.pumpAndSettle();
    expect(find.text('Pick a room'), findsNothing);
    expect(find.text('Room 1:0'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.state.toString(), '[RoomsRoute()]');
    expect(find.text('Pick a room'), findsOneWidget);
    expect(find.text('Rooms:1'), findsOneWidget);
  });
}
