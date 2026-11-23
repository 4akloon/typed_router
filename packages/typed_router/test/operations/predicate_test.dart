// Replace, popUntil, pushAndRemoveUntil: pushAndRemoveUntil that keeps nothing.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';

bool isRooms(TypedRoute<Object?> route) => route is RoomsRoute;
bool isProfile(TypedRoute<Object?> route) => route is ProfileRoute;

void main() {
  test('replace swaps the top entry and completes the replaced push with '
      'null', () async {
    final router = appRouter(rooms);
    final room = ResultProbe(router.push(room7));

    final note = ResultProbe(router.replace(editNote));
    await pumpEventQueue();

    expect(router.state.routes, const [rooms, editNote]);
    expect(room.completions, [null]);
    expect(note.isCompleted, isFalse);
  });

  test('popUntil removes entries until the predicate holds, with one '
      'notification', () async {
    final router = appRouter(rooms);
    final room = ResultProbe(router.push(room7));
    final note = ResultProbe(router.push(editNote));
    final notifications = NotificationCounter(router);

    router.popUntil(isRooms);
    await pumpEventQueue();

    expect(router.state.routes, const [rooms]);
    expect(notifications.count, 1);
    expect(room.completions, [null]);
    expect(note.completions, [null]);
  });

  test('popUntil without a match throws and changes nothing', () async {
    final router = appRouter(rooms);
    final room = ResultProbe(router.push(room7));
    final stateBefore = router.state;
    final notifications = NotificationCounter(router);

    expect(() => router.popUntil(isProfile), throwsStateError);
    await pumpEventQueue();

    expect(router.state, stateBefore);
    expect(notifications.count, 0);
    expect(room.isCompleted, isFalse);
  });

  test('pushAndRemoveUntil removes entries, then pushes, with one '
      'notification', () async {
    final router = appRouter(rooms);
    final room = ResultProbe(router.push(room7));
    final notifications = NotificationCounter(router);

    final note = ResultProbe(router.pushAndRemoveUntil(editNote, isRooms));
    await pumpEventQueue();

    expect(router.state.routes, const [rooms, editNote]);
    expect(notifications.count, 1);
    expect(room.completions, [null]);
    expect(note.isCompleted, isFalse);
  });

  test('pushAndRemoveUntil that keeps nothing leaves the route alone, as '
      'Navigator does', () async {
    final router = appRouter(rooms);
    final room = ResultProbe(router.push(room7));

    final note = ResultProbe(
      router.pushAndRemoveUntil(editNote, (route) => false),
    );
    await pumpEventQueue();

    expect(router.state.routes, const [editNote]);
    expect(room.completions, [null]);
    expect(note.isCompleted, isFalse);
  });
}
