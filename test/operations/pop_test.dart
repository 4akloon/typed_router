// Pop and typed results.

import 'package:flutter_test/flutter_test.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';

void main() {
  test('pop completes the push with the result, typed by the route', () async {
    final router = appRouter(rooms);
    final Future<String?> note = router.push(editNote);

    router.pop('Buy milk');

    expect(router.state.routes, const [rooms]);
    expect(await note, 'Buy milk');
  });

  test('pop without a result completes the push with null', () async {
    final router = appRouter(rooms);
    final note = router.push(editNote);

    router.pop();

    expect(await note, isNull);
  });

  test('pop with a result of another type fails and changes nothing', () async {
    final router = appRouter(rooms);
    final note = ResultProbe(router.push(editNote));
    final stateBefore = router.state;

    expect(
      () => router.pop(42),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          allOf(contains('EditNoteRoute'), contains('String')),
        ),
      ),
    );
    await pumpEventQueue();

    expect(router.state, stateBefore);
    expect(note.isCompleted, isFalse);
  });

  test('canPop reflects the stack and pop on one entry throws', () {
    final router = appRouter(rooms);

    expect(router.canPop, isFalse);
    expect(router.pop, throwsStateError);

    router.go(room7);

    expect(router.canPop, isTrue);
  });
}
