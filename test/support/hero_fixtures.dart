// Pages with heroes for: a small thumbnail on a list, a large picture on its
// detail, both tagged alike.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';

import 'route_fixtures.dart';
import 'tabs_fixtures.dart';
import 'tree_fixtures.dart';

/// A list page with a small hero tagged [tag] at the top left.
Widget thumbnailPage(String tag) => Align(
  alignment: Alignment.topLeft,
  child: Hero(
    tag: tag,
    child: SizedBox(key: ValueKey('$tag thumbnail'), width: 20, height: 20),
  ),
);

/// A detail page with a large hero tagged [tag] at the bottom right.
Widget detailPage(String tag) => Align(
  alignment: Alignment.bottomRight,
  child: Hero(
    tag: tag,
    child: SizedBox(key: ValueKey('$tag detail'), width: 300, height: 300),
  ),
);

/// Whether the hero tagged [tag] is in flight: what it shows lies in the
/// navigator's overlay, under no [Hero].
bool isInFlight(String tag) {
  final shown = find.byKey(ValueKey('$tag detail'), skipOffstage: false);
  return shown.evaluate().isNotEmpty &&
      find.ancestor(of: shown, matching: find.byType(Hero)).evaluate().isEmpty;
}

/// Users with a thumbnail and a user with a picture in a shell; an account
/// on the root.
List<TreeNode<NoParentRoute>> heroShellRoutes() => [
  ShellNode<NoParentRoute>(
    builder: (context, state, navigator) => navigator,
    children: [
      RouteNode<UsersRoute>(
        build: (context, users) => thumbnailPage('avatar'),
        children: [
          RouteNode<UserRoute>(
            build: (context, user) => detailPage('avatar'),
          ).withParent((user) => const UsersRoute()),
        ],
      ),
    ],
  ),
  RouteNode<AccountRoute>(build: (context, account) => const Text('Account')),
];

/// Rooms and friends tabs, each list with a thumbnail and each detail with
/// a picture.
List<TreeNode<NoParentRoute>> heroTabsRoutes() => [
  StatefulShellNode(
    builder: (context, state, shell) => shell,
    branches: [
      BranchNode<RoomsBranch>(
        initial: const RoomsRoute(),
        children: [
          RouteNode<RoomsRoute>(
            build: (context, rooms) => thumbnailPage('room'),
            children: [
              RouteNode<RoomRoute>(
                build: (context, room) => detailPage('room'),
              ).withParent((room) => const RoomsRoute()),
            ],
          ),
        ],
      ),
      BranchNode<FriendsBranch>(
        initial: friends,
        children: [
          RouteNode<FriendsRoute>(
            build: (context, friends) => thumbnailPage('friend'),
            children: [
              RouteNode<FriendRoute>(
                build: (context, friend) => detailPage('friend'),
              ).withParent((friend) => friends),
            ],
          ),
        ],
      ),
    ],
  ),
];

/// A Material app over [routes] started at [initialRoute].
Future<TypedRouter> pumpMaterialHeroes(
  WidgetTester tester,
  List<TreeNode<NoParentRoute>> routes,
  TypedRoute<Object?> initialRoute,
) async {
  final router = TypedRouter(
    routes: routes,
    initialRoute: initialRoute,
    pageFactory: const MaterialPageFactory(),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return router;
}

/// Pushes [route] and stops halfway through the page transition.
Future<void> pushHalfway(
  WidgetTester tester,
  TypedRouter router,
  TypedRoute<Object?> route,
) async {
  router.push(route).ignore();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
}

/// The hero controller of the navigator holding the list page with the
/// thumbnail tagged [tag], or `null`.
HeroController? heroControllerOf(WidgetTester tester, String tag) {
  final navigator = Navigator.of(
    tester.element(
      find.byKey(ValueKey('$tag thumbnail'), skipOffstage: false),
    ),
  );
  return HeroControllerScope.maybeOf(navigator.context);
}
