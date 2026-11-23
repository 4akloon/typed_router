// Listening, independence, dispose: a native pop after dispose.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import '../support/app_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/tree_fixtures.dart';

const rooms = RoomsRoute();
const room7 = RoomRoute(RoomId(7));

TypedRouter roomsRouter(TypedRoute<Object?> initialRoute) => TypedRouter(
  routes: roomsRoutes,
  initialRoute: initialRoute,
  pageFactory: const TestPageFactory(),
);

void main() {
  testWidgets('a ListenableBuilder builds the screen from the router state', (
    tester,
  ) async {
    final router = roomsRouter(room7);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ListenableBuilder(
          listenable: router,
          builder: (context, child) => Text('${router.state.top}'),
        ),
      ),
    );

    expect(find.text('RoomRoute(RoomId(7))'), findsOneWidget);
  });

  test('two routers from the same nodes are independent', () {
    final roomsList = roomsRouter(rooms);
    final room = roomsRouter(room7);

    expect(roomsList.state.routes, const [rooms]);
    expect(room.state.routes, const [rooms, room7]);

    roomsList.dispose();

    expect(room.state.routes, const [rooms, room7]);
    room
      ..addListener(() {})
      ..dispose();
  });

  test('after dispose the state stays readable, listeners can be removed '
      'but not added', () {
    final router = roomsRouter(room7);
    void listener() {}
    router
      ..addListener(listener)
      ..dispose();

    expect(router.state.routes, const [rooms, room7]);
    expect(() => router.removeListener(listener), returnsNormally);
    expect(() => router.addListener(() {}), throwsStateError);
  });

  test('disposing twice throws', () {
    final router = roomsRouter(rooms)..dispose();

    expect(router.dispose, throwsStateError);
  });

  test('toString shows the state', () {
    final router = roomsRouter(room7);
    addTearDown(router.dispose);

    expect('$router', 'TypedRouter(RoomsRoute() > RoomRoute(RoomId(7)))');
  });

  testWidgets('a native pop after dispose does not throw', (tester) async {
    final router = TypedRouter(
      routes: appRoutes,
      initialRoute: room7,
      pageFactory: const TestPageFactory(),
    );
    await pumpWidgetsRouter(tester, router);
    final navigator = Navigator.of(tester.element(find.text('Room 7')));
    router.dispose();

    expect(navigator.pop, returnsNormally);
    await tester.pumpAndSettle();
    expect(router.state.routes, const [rooms, room7]);
  });

  testWidgets('the navigator of a router disposed before it was shown is '
      'null', (tester) async {
    final router = TypedRouter(
      routes: appRoutes,
      initialRoute: rooms,
      pageFactory: const TestPageFactory(),
    )..dispose();

    expect(router.navigator, isNull);
  });
}
