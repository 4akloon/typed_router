// Creating a router.
//
// No testWidgets in this file: it initialises the widgets binding when it
// is declared, and one test needs a process without it.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/route_fixtures.dart';
import '../support/tree_fixtures.dart';

void main() {
  test('a router is created without a widgets binding', () {
    expect(BindingBase.debugBindingType(), isNull);

    final router = TypedRouter(
      routes: roomsRoutes,
      initialRoute: const RoomsRoute(),
    );

    expect(router.state.top, const RoomsRoute());
    expect(BindingBase.debugBindingType(), isNull);
  });

  test('a router starts at the initial route with its ancestors from the '
      'tree', () {
    final router = TypedRouter(
      routes: [...roomsRoutes, ...usersRoutes],
      initialRoute: const UserGamesRoute('u7'),
    );

    expect(router.state.routes, const [
      UsersRoute(),
      UserRoute('u7'),
      UserGamesRoute('u7'),
    ]);
  });

  test('a router started at a root route holds just that route', () {
    final router = TypedRouter(
      routes: roomsRoutes,
      initialRoute: const RoomsRoute(),
    );

    expect(router.state.routes, const [RoomsRoute()]);
  });

  test('a router without routes cannot be created', () {
    expect(
      () => TypedRouter(routes: const [], initialRoute: const RoomsRoute()),
      throwsArgumentError,
    );
  });

  test('a route type with two nodes fails the router even when the initial '
      'route is fine', () {
    expect(
      () => TypedRouter(
        routes: [...roomsRoutes, ...authRoutes, ...authRoutes],
        initialRoute: const RoomsRoute(),
      ),
      throwsArgumentError,
    );
  });

  test('an initial route without a node fails the router and names its '
      'type', () {
    expect(
      () => TypedRouter(routes: roomsRoutes, initialRoute: const SignInRoute()),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          contains('SignInRoute'),
        ),
      ),
    );
  });
}
