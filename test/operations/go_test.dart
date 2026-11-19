// Go.

import 'package:flutter_test/flutter_test.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';

void main() {
  test('go builds the ancestors of the route from the tree', () {
    final router = appRouter(rooms);

    router.go(room8);

    expect(router.state.routes, const [rooms, room8]);
  });

  testWidgets('go keeps the entries of the common prefix with their screen '
      'state', (tester) async {
    final router = appRouter(room7);
    await pumpWidgetsRouter(tester, router);
    final roomsState = tester.state(
      find.byType(RoomsScreen, skipOffstage: false),
    );

    router.go(room8);
    await tester.pumpAndSettle();

    expect(router.state.routes, const [rooms, room8]);
    expect(find.text('Room 8'), findsOneWidget);
    expect(
      tester.state(find.byType(RoomsScreen, skipOffstage: false)),
      same(roomsState),
    );
  });

  test('go to the current chain changes nothing and notifies nobody', () {
    final router = appRouter(room7);
    final stateBefore = router.state;
    final notifications = NotificationCounter(router);

    router.go(room7);

    expect(router.state, stateBefore);
    expect(notifications.count, 0);
  });

  test('go completes the pushes of the entries it removes with null', () async {
    final router = appRouter(rooms);
    final note = router.push(editNote);

    router.go(room7);

    expect(router.state.routes, const [rooms, room7]);
    expect(await note, isNull);
  });

  test('pushes of entries go keeps stay pending', () async {
    final router = appRouter(rooms);
    final room = ResultProbe(router.push(room7));
    final note = ResultProbe(router.push(editNote));

    router.go(room7);
    await pumpEventQueue();

    expect(router.state.routes, const [rooms, room7]);
    expect(note.completions, [null]);
    expect(room.isCompleted, isFalse);
  });
}
