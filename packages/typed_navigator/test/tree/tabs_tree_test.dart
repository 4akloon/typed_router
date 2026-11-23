// Tabs and their branches in the tree.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/src/tree/nesting.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/route_fixtures.dart';

class RoomsBranch {}

class AccountBranch {}

Widget _frame(
  BuildContext context,
  TypedRouterState state,
  StatefulShell shell,
) => shell;

RouteNode<RoomsRoute> _roomsNode() => RouteNode<RoomsRoute>(
  build: (context, rooms) => const Text('Rooms'),
  children: [
    RouteNode<RoomRoute>(
      build: (context, room) => const Text('Room'),
    ).withParent((room) => const RoomsRoute()),
  ],
);

RouteNode<AccountRoute> _accountNode() =>
    RouteNode<AccountRoute>(build: (context, account) => const Text(''));

void main() {
  test('a route of a branch knows its tabs and branch', () {
    final tabs = StatefulShellNode(
      builder: _frame,
      branches: [
        BranchNode<RoomsBranch>(
          initial: const RoomsRoute(),
          children: [_roomsNode()],
        ),
        BranchNode<AccountBranch>(
          initial: const AccountRoute(),
          children: [_accountNode()],
        ),
      ],
    );

    final tree = RouteTree([tabs]);

    expect(tree.chainTo(const RoomRoute(RoomId(7))), const [
      RoomsRoute(),
      RoomRoute(RoomId(7)),
    ]);
    expect(tree.nestingsOf(const RoomRoute(RoomId(7))), [
      BranchNesting(tabs, RoomsBranch),
    ]);
    expect(tree.nestingsOf(const AccountRoute()), [
      BranchNesting(tabs, AccountBranch),
    ]);
  });

  test('tabs without branches, a repeated branch, an empty branch or a '
      'foreign initial fail when the router is built', () {
    Matcher fails(String message) => throwsA(
      isA<ArgumentError>().having((error) => error.message, 'message', message),
    );
    RouteTree treeWith(List<BranchNode<Object?>> branches) =>
        RouteTree([StatefulShellNode(builder: _frame, branches: branches)]);

    expect(
      () => treeWith(const []),
      fails(
        'A StatefulShellNode has no branches. Give it at least one '
        'BranchNode.',
      ),
    );
    expect(
      () => treeWith([
        BranchNode<RoomsBranch>(
          initial: const RoomsRoute(),
          children: [_roomsNode()],
        ),
        BranchNode<RoomsBranch>(
          initial: const AccountRoute(),
          children: [_accountNode()],
        ),
      ]),
      fails(
        'Branch RoomsBranch appears twice in a StatefulShellNode. Give '
        'every branch its own type.',
      ),
    );
    expect(
      () => treeWith([
        const BranchNode<RoomsBranch>(initial: RoomsRoute(), children: []),
      ]),
      fails('Branch RoomsBranch has no children. Give it at least one node.'),
    );
    expect(
      () => treeWith([
        BranchNode<RoomsBranch>(
          initial: const AccountRoute(),
          children: [_roomsNode()],
        ),
      ]),
      fails(
        'The initial route AccountRoute() of branch RoomsBranch is not in '
        'that branch. Use a route of the branch\'s subtree.',
      ),
    );
  });
}
