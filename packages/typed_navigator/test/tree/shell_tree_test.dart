// A shell is a node in the tree, transparent for the parent type of its
// children.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/src/tree/nesting.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/tree_fixtures.dart';

Widget _frame(BuildContext context, TypedRouterState state, Widget navigator) =>
    navigator;

void main() {
  final userShell = ShellNode<UsersRoute>(
    builder: _frame,
    children: [
      RouteNode<UserRoute>(
        build: (context, user) => Text(user.userId),
      ).withParent((user) => const UsersRoute()),
    ],
  );
  final usersShell = ShellNode<NoParentRoute>(
    builder: _frame,
    children: [
      RouteNode<UsersRoute>(
        build: (context, users) => const Text('Users'),
        children: [userShell],
      ),
    ],
  );

  test('a child of a shell chains to the parent above the shell', () {
    final tree = RouteTree([usersShell]);

    expect(tree.chainTo(const UserRoute('u1')), const [
      UsersRoute(),
      UserRoute('u1'),
    ]);
  });

  test('a route knows the shells around it, from the outer one in', () {
    final tree = RouteTree([usersShell]);

    expect(tree.nestingsOf(const UsersRoute()), [
      ShellNesting(usersShell),
    ]);
    expect(tree.nestingsOf(const UserRoute('u1')), [
      ShellNesting(usersShell),
      ShellNesting(userShell),
    ]);
  });

  test('a shell without children fails when the router is built', () {
    expect(
      () => RouteTree([
        const ShellNode<NoParentRoute>(builder: _frame, children: []),
      ]),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'A ShellNode has no children. Give it at least one node.',
        ),
      ),
    );
  });
}
