// Results complete once; dispose and misuse.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';

TypedRouter undisposedRouter() => TypedRouter(
  routes: appRoutes,
  initialRoute: rooms,
  pageFactory: const TestPageFactory(),
);

void main() {
  testWidgets('a push completes once when pop is followed by the navigator '
      'removing its page', (tester) async {
    final router = appRouter(rooms);
    await pumpWidgetsRouter(tester, router);
    final note = ResultProbe(router.push(editNote));
    await tester.pumpAndSettle();

    router.pop('Buy milk');
    await tester.pumpAndSettle();

    expect(note.completions, ['Buy milk']);
    expect(tester.takeException(), isNull);
  });

  test('dispose completes every pending push with null', () async {
    final router = undisposedRouter();
    final room = ResultProbe(router.push(room7));
    final note = ResultProbe(router.push(editNote));

    router.dispose();
    await pumpEventQueue();

    expect(room.completions, [null]);
    expect(note.completions, [null]);
  });

  testWidgets('operations after dispose throw and during build fail in '
      'debug', (tester) async {
    final disposed = undisposedRouter()..dispose();
    expect(() => disposed.go(room7), throwsStateError);
    expect(() => disposed.push(room7), throwsStateError);

    final router = appRouter(rooms);
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          router.go(room7);
          return const SizedBox();
        },
      ),
    );

    expect(tester.takeException(), isA<AssertionError>());
    expect(router.state.routes, const [rooms]);
  });
}
