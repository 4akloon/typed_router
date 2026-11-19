// Push and every operation's commit.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';

void main() {
  testWidgets('push puts the route on top without its ancestors, shown in '
      'the next frame', (tester) async {
    final router = appRouter(room7);
    await pumpWidgetsRouter(tester, router);

    unawaited(router.push(room8));

    expect(router.state.routes, const [rooms, room7, room8]);
    expect(find.text('Room 8'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('Room 8'), findsOneWidget);
  });

  test('pushing an equal route twice gives two entries', () {
    final router = appRouter(rooms);

    unawaited(router.push(room7));
    unawaited(router.push(room7));

    expect(router.state.routes, const [rooms, room7, room7]);
  });

  test('pushing a route without a node fails and changes nothing', () {
    final router = appRouter(rooms);
    final stateBefore = router.state;

    expect(() => router.push(routeWithoutNode), throwsArgumentError);
    expect(router.state, stateBefore);
  });

  testWidgets('operations before mounting change the state the navigator '
      'then shows', (tester) async {
    final router = appRouter(rooms);

    unawaited(router.push(room7));
    await pumpWidgetsRouter(tester, router);

    expect(find.text('Room 7'), findsOneWidget);
  });

  test('every operation notifies listeners once', () {
    final router = appRouter(rooms);
    final notifications = NotificationCounter(router);
    final operations = <void Function()>[
      () => router.go(room7),
      () => unawaited(router.push(room8)),
      () => unawaited(router.replace(editNote)),
      router.pop<void>,
      () => router.popUntil((route) => route is RoomsRoute),
      () => unawaited(
        router.pushAndRemoveUntil(room8, (route) => route is RoomsRoute),
      ),
    ];

    for (final (index, operation) in operations.indexed) {
      operation();
      expect(notifications.count, index + 1, reason: 'operation $index');
    }
  });
}
