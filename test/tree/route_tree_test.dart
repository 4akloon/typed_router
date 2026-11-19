// The route tree. Tests the internal RouteTree on purpose, apart from the
// router.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/route_fixtures.dart';
import '../support/tree_fixtures.dart';

RouteTree appTree() =>
    RouteTree([...authRoutes, ...roomsRoutes, ...usersRoutes]);

void main() {
  group('chain', () {
    test('a top-level route\'s chain is the route itself', () {
      expect(appTree().chainTo(const SignInRoute()), [const SignInRoute()]);
    });

    test('a child route\'s chain starts with the parent it builds', () {
      expect(appTree().chainTo(const RoomRoute(RoomId(7))), [
        const RoomsRoute(),
        const RoomRoute(RoomId(7)),
      ]);
    });

    test('a parent built from the child\'s fields reaches three levels', () {
      expect(appTree().chainTo(const UserGamesRoute('u1')), [
        const UsersRoute(),
        const UserRoute('u1'),
        const UserGamesRoute('u1'),
      ]);
    });

    test('withParent receives the exact route the chain is built for', () {
      final received = <UserGamesRoute>[];
      final tree = RouteTree([
        RouteNode<UserRoute>(
          build: emptyScreen,
          children: [
            const RouteNode<UserGamesRoute>(build: emptyScreen)
                .withParent((games) {
                  received.add(games);
                  return UserRoute(games.userId);
                }),
          ],
        ),
      ]);

      tree.chainTo(const UserGamesRoute('u2'));

      expect(received, [const UserGamesRoute('u2')]);
    });

    test('a node placed with withParent can have children of its own', () {
      expect(appTree().chainTo(const UserRoute('u1')), [
        const UsersRoute(),
        const UserRoute('u1'),
      ]);
    });

    test('subtrees from separate feature lists compose into one tree', () {
      final tree = appTree();

      expect(tree.chainTo(const SignInRoute()), hasLength(1));
      expect(tree.chainTo(const RoomRoute(RoomId(1))), hasLength(2));
      expect(tree.chainTo(const UserGamesRoute('u1')), hasLength(3));
    });
  });

  group('validation', () {
    test('a route type registered twice fails when the tree is built', () {
      expect(
        () => RouteTree([...authRoutes, ...authRoutes]),
        throwsArgumentError,
      );
      expect(
        () => RouteTree([
          ...roomsRoutes,
          RouteNode<RoomsRoute>(
            build: emptyScreen,
            children: [
              const RouteNode<RoomRoute>(
                build: emptyScreen,
              ).withParent((_) => const RoomsRoute()),
            ],
          ),
        ]),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains('RoomsRoute'),
          ),
        ),
      );
    });

    test('asking for an unregistered route fails and names the type', () {
      expect(
        () => RouteTree(authRoutes).chainTo(const RoomsRoute()),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains('RoomsRoute'),
          ),
        ),
      );
    });

    test('an empty tree fails when it is built', () {
      expect(() => RouteTree(const []), throwsArgumentError);
    });
  });
}
