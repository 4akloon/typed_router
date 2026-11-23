// A route placed in another navigator keeps its nesting in the tree for
// redirects.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/src/tree/nesting.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/route_fixtures.dart';

Widget _frame(BuildContext context, TypedRouterState state, Widget navigator) =>
    navigator;

void main() {
  test('a route placed on the root is shown at the root and guarded by its '
      'shell; its children follow it', () {
    final shell = ShellNode<NoParentRoute>(
      builder: _frame,
      children: [
        RouteNode<RoomsRoute>(
          build: (context, rooms) => const Text('Rooms'),
          children: [
            RouteNode<RoomRoute>(
              build: (context, room) => const Text('Room'),
              parentNavigatorSlot: NavigatorSlot.root,
              children: [
                RouteNode<EditNoteRoute>(
                  build: (context, note) => const Text('Note'),
                ).withParent((note) => const RoomRoute(RoomId(1))),
              ],
            ).withParent((room) => const RoomsRoute()),
          ],
        ),
      ],
    );

    final tree = RouteTree([shell]);

    expect(tree.nestingsOf(const RoomsRoute()), [ShellNesting(shell)]);
    expect(tree.nestingsOf(const RoomRoute(RoomId(7))), isEmpty);
    expect(tree.nestingsOf(const EditNoteRoute()), isEmpty);
    expect(tree.guardingNestingsOf(const RoomRoute(RoomId(7))), [
      ShellNesting(shell),
    ]);
  });

  test('a foreign slot or a slot on two nodes fails when the router is '
      'built', () {
    Matcher fails(String message) => throwsA(
      isA<ArgumentError>().having((error) => error.message, 'message', message),
    );
    final foreign = NavigatorSlot();
    final shared = NavigatorSlot();

    expect(
      () => RouteTree([
        RouteNode<RoomsRoute>(
          build: (context, rooms) => const Text('Rooms'),
          parentNavigatorSlot: foreign,
        ),
      ]),
      fails(
        "RoomsRoute's parentNavigatorSlot is neither the root nor the slot "
        'of a shell or branch above it. Use NavigatorSlot.root or the slot '
        'of an enclosing ShellNode or BranchNode.',
      ),
    );
    expect(
      () => RouteTree([
        ShellNode<NoParentRoute>(
          builder: _frame,
          navigatorSlot: shared,
          children: [
            ShellNode<NoParentRoute>(
              builder: _frame,
              navigatorSlot: shared,
              children: [
                RouteNode<RoomsRoute>(
                  build: (context, rooms) => const Text('Rooms'),
                ),
              ],
            ),
          ],
        ),
      ]),
      fails(
        'A NavigatorSlot is given to two shells or branches. Give each its '
        'own slot.',
      ),
    );
  });
}
