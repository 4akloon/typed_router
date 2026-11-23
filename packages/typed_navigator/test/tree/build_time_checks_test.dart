// Mistakes the compiler lets through fail when the router is built, naming the
// node.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/route_fixtures.dart';

class _RoomsBranch {}

class _AccountBranch {}

Widget _frame(
  BuildContext context,
  NavigationState state,
  StatefulShell shell,
) => shell;

Matcher _argumentErrorSaying(String text) => throwsA(
  isArgumentError.having(
    (error) => '${error.message}',
    'message',
    contains(text),
  ),
);

RouteNode<RoomsRoute> _roomsNode() =>
    RouteNode<RoomsRoute>(build: (context, rooms) => const Text('Rooms'));

void main() {
  test('a node without a route type fails when the router is built', () {
    expect(
      () => RouteTree([
        _roomsNode(),
        RouteNode(build: (context, route) => const Text('Untyped')),
      ]),
      _argumentErrorSaying('RouteNode<'),
    );
  });

  test('a branch without a type fails when the router is built', () {
    expect(
      () => RouteTree([
        StatefulShellNode(
          builder: _frame,
          branches: [
            BranchNode(initial: const RoomsRoute(), children: [_roomsNode()]),
          ],
        ),
      ]),
      _argumentErrorSaying('BranchNode<'),
    );
  });

  test("a branch's initial shown outside its navigator fails", () {
    expect(
      () => RouteTree([
        StatefulShellNode(
          builder: _frame,
          branches: [
            BranchNode<_RoomsBranch>(
              initial: const RoomsRoute(),
              children: [_roomsNode()],
            ),
            BranchNode<_AccountBranch>(
              initial: const AccountRoute(),
              children: [
                RouteNode<AccountRoute>(
                  parentNavigatorSlot: NavigatorSlot.root,
                  build: (context, account) => const Text('Account'),
                ),
              ],
            ),
          ],
        ),
      ]),
      _argumentErrorSaying('_AccountBranch'),
    );
  });

  test('a node whose parent is Never fails naming the node', () {
    expect(
      () => RouteTree([
        _roomsNode(),
        RouteNode<RoomRoute>(
          name: 'room',
          build: (context, room) => const Text('Room'),
        ).withParent((room) => throw UnimplementedError()),
      ]),
      _argumentErrorSaying('room'),
    );
  });
}
