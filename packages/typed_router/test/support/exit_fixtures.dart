// Apps for the onExit tests: rooms with a room and a note editor whose nodes
// ask before they leave, the same room in tabs and in a shell.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';

import 'material_page_factory.dart';
import 'operation_fixtures.dart';
import 'route_fixtures.dart';
import 'tabs_fixtures.dart';

const account = AccountRoute();

/// Records every onExit call and answers it with [answer].
class ExitLog {
  /// The routes asked, in order.
  final List<TypedRoute<Object?>> asked = [];

  /// The target each call saw.
  final List<TypedRouterState> targets = [];

  /// How the hooks answer; a test sets it.
  FutureOr<bool> Function(TypedRoute<Object?> route) answer = (route) => true;

  /// The hook of the test's nodes.
  FutureOr<bool> ask(TypedRoute<Object?> route, TypedRouterState target) {
    asked.add(route);
    targets.add(target);
    return answer(route);
  }

  /// Makes every hook wait for the returned completer.
  Completer<bool> answerLater() {
    final completer = Completer<bool>();
    answer = (route) => completer.future;
    return completer;
  }
}

/// A room whose node asks [log] before it leaves.
RouteNode<RoomRoute> askingRoom(ExitLog log) => RouteNode<RoomRoute>(
  build: (context, room) => Text('Room ${room.id.value}'),
  onExit: (context, room, target) => log.ask(room, target),
);

/// Rooms with an asking room, an asking note editor and an account that does
/// not ask.
List<TreeNode<NoParentRoute>> exitRoutes(ExitLog log) => [
  RouteNode<RoomsRoute>(
    build: (context, rooms) => const Text('Rooms'),
    children: [askingRoom(log).withParent((room) => const RoomsRoute())],
  ),
  RouteNode<EditNoteRoute>(
    build: (context, note) => const Text('Edit note'),
    onExit: (context, note, target) => log.ask(note, target),
  ),
  RouteNode<AccountRoute>(build: (context, account) => const Text('Account')),
];

/// Tabs of rooms (with the asking room) and friends; account on the root.
List<TreeNode<NoParentRoute>> exitTabsRoutes(ExitLog log) => [
  StatefulShellNode(
    builder: (context, state, shell) => shell,
    branches: [
      BranchNode<RoomsBranch>(
        initial: rooms,
        children: [
          RouteNode<RoomsRoute>(
            build: (context, rooms) => const Text('Rooms'),
            children: [
              askingRoom(log).withParent((room) => const RoomsRoute()),
            ],
          ),
        ],
      ),
      friendsBranch(ScreenLog()),
    ],
  ),
  RouteNode<AccountRoute>(build: (context, account) => const Text('Account')),
];

/// Rooms and the asking room inside a shell; account on the root.
List<TreeNode<NoParentRoute>> exitShellRoutes(ExitLog log) => [
  ShellNode(
    builder: (context, state, navigator) => navigator,
    children: exitRoutes(log).take(1).toList(),
  ),
  RouteNode<AccountRoute>(build: (context, account) => const Text('Account')),
];

/// A Material router over [routes] (by default [exitRoutes] of [log]) at
/// [initialRoute], shown and settled; disposed when the test ends.
Future<TypedRouter> pumpExitApp(
  WidgetTester tester,
  ExitLog log, {
  TypedRoute<Object?> initialRoute = room7,
  List<TreeNode<NoParentRoute>>? routes,
  TypedRoute<Object?>? Function(BuildContext context, TypedRouterState target)?
  redirect,
  Listenable? refreshListenable,
  ThemeData? theme,
}) async {
  final router = TypedRouter(
    routes: routes ?? exitRoutes(log),
    initialRoute: initialRoute,
    pageFactory: const MaterialPageFactory(),
    redirect: redirect,
    refreshListenable: refreshListenable,
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(routerConfig: router, theme: theme),
  );
  await tester.pumpAndSettle();
  return router;
}
