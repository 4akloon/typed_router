// On the error screen, an operation checks the routes below its own, not only
// the new route.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import '../support/app_fixtures.dart';
import '../support/redirect_fixtures.dart';
import '../support/route_fixtures.dart';

void main() {
  testWidgets('push on the error screen re-checks the routes below', (
    tester,
  ) async {
    var isFailing = false;
    final router = TypedRouter(
      routes: [
        RouteNode<HomeRoute>(build: (context, home) => const Text('Home')),
        RouteNode<EditNoteRoute>(
          build: (context, note) => const Text('Edit note'),
          redirect: (context, note, target) =>
              isFailing ? throw StateError('service down') : null,
        ),
        RouteNode<RoomsRoute>(build: (context, rooms) => const Text('Rooms')),
      ],
      initialRoute: const HomeRoute(),
      pageFactory: const TestPageFactory(),
      errorBuilder: (context, error) => const Text('Failed'),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);
    router.push(const EditNoteRoute()).ignore();
    await tester.pumpAndSettle();
    isFailing = true;
    router.refresh();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isStateError);

    router.push(const RoomsRoute()).ignore();
    await tester.pumpAndSettle();
    tester.takeException();
    expect(router.state.error, isNotNull);
    expect(find.text('Failed'), findsOneWidget);
  });
}
