// A screen reads the state reactively, and finds the route right above its own.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/shell_fixtures.dart' show settleAfter;
import '../support/state_fixtures.dart';

/// Shows the state's top route, read through [TypedRouterState.of].
class _TopLabel extends StatelessWidget {
  const _TopLabel();

  @override
  Widget build(BuildContext context) =>
      Text('top ${TypedRouterState.of(context).top}');
}

Future<TypedRouter> _pump(WidgetTester tester) async {
  final router = TypedRouter(
    routes: [
      RouteNode<RoomsRoute>(
        build: (context, rooms) => const _TopLabel(),
        children: [
          RouteNode<RoomRoute>(
            build: (context, room) => Text('Room ${room.id.value}'),
          ).withParent((room) => const RoomsRoute()),
        ],
      ),
    ],
    initialRoute: rooms,
    pageFactory: const TestPageFactory(),
  );
  addTearDown(router.dispose);
  await pumpWidgetsRouter(tester, router);
  await tester.pumpAndSettle();
  return router;
}

Finder _label(String top) => find.text('top $top', skipOffstage: false);

void main() {
  testWidgets('a const screen reading TypedRouterState.of rebuilds on every '
      'navigation', (tester) async {
    final router = await _pump(tester);
    expect(_label('RoomsRoute()'), findsOneWidget);

    await settleAfter(tester, () => router.push(room7).ignore());
    expect(_label('RoomRoute(RoomId(7))'), findsOneWidget);

    await settleAfter(tester, () => router.go(room8));
    expect(_label('RoomRoute(RoomId(8))'), findsOneWidget);

    await settleAfter(tester, () => router.pop(null));
    expect(_label('RoomsRoute()'), findsOneWidget);

    await settleAfter(tester, () => router.push(room7).ignore());
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_label('RoomsRoute()'), findsOneWidget);
  });

  testWidgets('TypedRouterState.of without a router throws FlutterError', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: _TopLabel(),
      ),
    );

    expect(
      tester.takeException(),
      isA<FlutterError>().having(
        (error) => error.message,
        'message',
        contains('TypedRouterState.of() found no router'),
      ),
    );
  });

  test('routeAfter answers the route above the entry nearest to the top, '
      'null on top or missing', () {
    final state = stateOf([rooms, room7, rooms, room8]);

    expect(state.routeAfter(rooms), room8);
    expect(state.routeAfter(room7), rooms);
    expect(state.routeAfter(room8), isNull);
    expect(state.routeAfter(const RoomRoute(RoomId(9))), isNull);
  });
}
