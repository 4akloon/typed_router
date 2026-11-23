// The order of redirects, chains, the limit and loops.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/redirect_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/step_fixtures.dart';

void main() {
  testWidgets('the router redirect runs first and the first redirect wins', (
    tester,
  ) async {
    final calls = <String>[];
    final router = sessionRouter(Session(), calls: calls);
    await pumpWidgetsRouter(tester, router);
    calls.clear();

    router.go(room7);

    // The rooms guard won; the room's own redirect never ran.
    expect(calls, [
      'router: RoomRoute(RoomId(7))',
      'Rooms node: RoomsRoute() for RoomRoute(RoomId(7))',
      'router: SignInRoute(RoomRoute(RoomId(7)))',
    ]);
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('a redirect target goes through every redirect again', (
    tester,
  ) async {
    var routerRedirects = 0;
    final router = stepRouter(
      next: stepsUpTo(3),
      redirect: (context, target) {
        routerRedirects++;
        return null;
      },
    );
    await pumpWidgetsRouter(tester, router);
    routerRedirects = 0;

    router.go(const StepRoute(0));

    expect(router.state.routes, const [rooms, StepRoute(3)]);
    expect(routerRedirects, 4);
    await tester.pumpAndSettle();
    expect(find.text('Step 3'), findsOneWidget);
  });

  testWidgets('a chain of redirectLimit redirects succeeds and one more '
      'fails', (tester) async {
    // The router's redirect takes one hop, the steps the rest: one limit.
    final router = stepRouter(
      next: stepsUpTo(4),
      redirect: (context, target) =>
          target.top is EditNoteRoute ? const StepRoute(0) : null,
    );
    await pumpWidgetsRouter(tester, router);

    router.go(editNote);
    expect(router.state.routes, const [rooms, StepRoute(4)]);
    expect(tester.takeException(), isNull);

    final longer = stepRouter(next: stepsUpTo(6));
    await pumpWidgetsRouter(tester, longer);
    longer.go(const StepRoute(0));

    expect(longer.state.routes, const [HomeRoute()]);
    expect(
      tester.takeException(),
      isA<RedirectChainError>().having((error) => error.chain, 'chain', [
        for (var number = 0; number <= 6; number++) StepRoute(number),
      ]),
    );
    await tester.pump();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('a redirect loop fails with the chain', (tester) async {
    final router = stepRouter(next: (number) => StepRoute((number + 1) % 3));
    await pumpWidgetsRouter(tester, router);

    router.go(const StepRoute(0));

    expect(router.state.routes, const [HomeRoute()]);
    expect(
      tester.takeException(),
      // Stopped at the first repeat, not by the limit.
      isA<RedirectChainError>()
          .having((error) => error.chain, 'chain', const [
            StepRoute(0),
            StepRoute(1),
            StepRoute(2),
            StepRoute(0),
          ])
          .having((error) => '$error', 'message', contains('Redirects loop')),
    );
  });
}
