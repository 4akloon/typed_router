// Levels inside levels for the back gesture tests: a shell nested in a shell.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';

import 'back_fixtures.dart';
import 'route_fixtures.dart';
import 'tree_fixtures.dart';

/// Users in a shell; a user in a shell of its own under them, framed by
/// 'User frame'; an account page on the root.
List<TreeNode<NoParentRoute>> nestedShellRoutes() => [
  ShellNode<NoParentRoute>(
    builder: (context, state, navigator) => navigator,
    children: [
      RouteNode<UsersRoute>(
        build: (context, users) => const Text('Users'),
        children: [
          ShellNode<UsersRoute>(
            builder: (context, state, navigator) => Column(
              children: [
                const Text('User frame'),
                Expanded(child: navigator),
              ],
            ),
            children: [
              RouteNode<UserRoute>(
                build: (context, user) => Text('User ${user.userId}'),
              ).withParent((user) => const UsersRoute()),
            ],
          ),
        ],
      ),
    ],
  ),
  RouteNode<AccountRoute>(build: (context, account) => const Text('Account')),
];

/// A Material app over [routes] with [predictiveBackTheme], started at
/// [initialRoute]; disposed when the test ends.
Future<TypedRouter> pumpMaterialAt(
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
  await tester.pumpWidget(
    MaterialApp.router(routerConfig: router, theme: predictiveBackTheme),
  );
  await tester.pumpAndSettle();
  return router;
}
