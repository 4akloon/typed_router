// Three shells one inside another, slots to every level, and the limit of a
// placed route's children.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_test/typed_navigator_test.dart';

import '../support/app_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/tabs_fixtures.dart';
import '../support/tree_fixtures.dart';

Widget _frame(BuildContext context, NavigationState state, Widget navigator) =>
    navigator;

/// Shells A > B > C; a room route in C shows in A, its note child in
/// [noteSlot] (A's by default).
List<TreeNode<NoParentRoute>> _threeShells(
  NavigatorSlot outer,
  NavigatorSlot middle, {
  NavigatorSlot? noteSlot,
}) => [
  ShellNode<NoParentRoute>(
    builder: _frame,
    navigatorSlot: outer,
    children: [
      RouteNode<UsersRoute>(
        build: (context, users) => const Text('Users'),
        children: [
          ShellNode<UsersRoute>(
            builder: _frame,
            navigatorSlot: middle,
            children: [
              RouteNode<UserRoute>(
                build: (context, user) => Text('User ${user.userId}'),
                children: [
                  ShellNode<UserRoute>(
                    builder: _frame,
                    children: [
                      RouteNode<UserGamesRoute>(
                        build: (context, games) => const Text('Games'),
                      ).withParent((games) => UserRoute(games.userId)),
                      RouteNode<RoomRoute>(
                        build: (context, room) => Text('Room ${room.id.value}'),
                        parentNavigatorSlot: outer,
                        children: [
                          RouteNode<EditNoteRoute>(
                            build: (context, note) => const Text('Note'),
                            parentNavigatorSlot: noteSlot,
                          ).withParent((note) => const RoomRoute(RoomId(1))),
                        ],
                      ).withParent((room) => const UserRoute('u1')),
                    ],
                  ),
                ],
              ).withParent((user) => const UsersRoute()),
            ],
          ),
        ],
      ),
    ],
  ),
];

void main() {
  testWidgets('three nested shells: the deepest by default, an outer one by '
      'slot, back from the deepest navigator out', (tester) async {
    final router = TypedRouter(
      routes: _threeShells(NavigatorSlot(), NavigatorSlot()),
      initialRoute: const UsersRoute(),
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);

    await settled(tester, () => router.go(const UserGamesRoute('u1')));
    expect(
      router.state.toString(),
      '[UsersRoute() > [UserRoute(u1) > [UserGamesRoute(u1)]]]',
    );
    expect(find.text('Games'), findsOneWidget);

    await settled(tester, () => router.go(const EditNoteRoute()));
    expect(
      router.state.toString(),
      '[UsersRoute() > [UserRoute(u1)] > RoomRoute(RoomId(1)) > '
      'EditNoteRoute()]',
    );
    expect(find.text('Note'), findsOneWidget);

    await tester.systemBack();
    await tester.systemBack();
    expect(router.state.toString(), '[UsersRoute() > [UserRoute(u1)]]');
    expect(find.text('User u1'), findsOneWidget);
    await tester.systemBack();
    expect(router.state.toString(), '[UsersRoute()]');
    expect(find.text('Users'), findsOneWidget);
  });

  test('a child of a placed route asking for a deeper navigator fails when '
      'the router is built', () {
    final middle = NavigatorSlot();

    expect(
      () => TypedRouter(
        routes: _threeShells(NavigatorSlot(), middle, noteSlot: middle),
        initialRoute: const UsersRoute(),
        pageFactory: const TestPageFactory(),
      ),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          "EditNoteRoute's parentNavigatorSlot names a navigator deeper than "
              'the one its parent route is shown in. A route shows in its '
              "parent's navigator or further out: use that navigator's slot "
              'or an outer one.',
        ),
      ),
    );
  });
}
