// Sample route trees for tests: the rooms feature and a users feature with a
// parent built from the child's fields, declared as separate feature lists.

import 'package:flutter/widgets.dart';
import 'package:typed_navigator/typed_navigator.dart';

import 'route_fixtures.dart';

/// A route without fields at the top of the users feature.
class UsersRoute extends TypedRoute<void> {
  const UsersRoute();

  @override
  List<Object?> get fields => const [];
}

/// A user's page; its parent is [UsersRoute].
class UserRoute extends TypedRoute<void> {
  const UserRoute(this.userId);

  final String userId;

  @override
  List<Object?> get fields => [userId];
}

/// A user's games; its parent [UserRoute] is built from [userId].
class UserGamesRoute extends TypedRoute<void> {
  const UserGamesRoute(this.userId);

  final String userId;

  @override
  List<Object?> get fields => [userId];
}

/// A top-level route of an auth feature.
class SignInRoute extends TypedRoute<void> {
  const SignInRoute();

  @override
  List<Object?> get fields => const [];
}

/// A screen that shows nothing; trees in these tests are never rendered.
Widget emptyScreen(BuildContext context, Object? route) =>
    const SizedBox.shrink();

/// Rooms feature: the list and a room under it.
final List<TreeNode<NoParentRoute>> roomsRoutes = [
  RouteNode<RoomsRoute>(
    build: emptyScreen,
    children: [
      const RouteNode<RoomRoute>(
        build: emptyScreen,
      ).withParent((_) => const RoomsRoute()),
    ],
  ),
];

/// Users feature: three levels, the last one builds its parent from its own
/// fields.
final List<TreeNode<NoParentRoute>> usersRoutes = [
  RouteNode<UsersRoute>(
    build: emptyScreen,
    children: [
      RouteNode<UserRoute>(
        build: emptyScreen,
        children: [
          const RouteNode<UserGamesRoute>(
            build: emptyScreen,
          ).withParent((games) => UserRoute(games.userId)),
        ],
      ).withParent((_) => const UsersRoute()),
    ],
  ),
];

/// Auth feature: one top-level route.
final List<TreeNode<NoParentRoute>> authRoutes = [
  const RouteNode<SignInRoute>(build: emptyScreen),
];
