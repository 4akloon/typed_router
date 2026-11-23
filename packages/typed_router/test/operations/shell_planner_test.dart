// The planner places routes in shell instances. Tests the internal planner on
// purpose: which instance a route lands in is logic of its own.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/src/operation/branch_switch.dart';
import 'package:typed_router/src/operation/entry_chain.dart';
import 'package:typed_router/src/operation/go_plan.dart';
import 'package:typed_router/src/operation/in_place_update.dart';
import 'package:typed_router/src/operation/navigation_planner.dart';
import 'package:typed_router/src/operation/shell_path.dart';
import 'package:typed_router/src/page/route_pages.dart';
import 'package:typed_router/src/state/shell_level.dart';
import 'package:typed_router/src/tree/route_tree.dart';
import 'package:typed_router/typed_router.dart';

import '../support/app_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/tree_fixtures.dart';

const user1 = UserRoute('u1');
const user2 = UserRoute('u2');
const account = AccountRoute();

final planner = _plannerOver(
  RouteTree([
    ShellNode<NoParentRoute>(
      builder: (context, state, navigator) => navigator,
      children: [
        RouteNode<UsersRoute>(
          build: (context, users) => const Text('Users'),
          children: [
            RouteNode<UserRoute>(
              build: (context, user) => Text(user.userId),
            ).withParent((user) => const UsersRoute()),
          ],
        ),
      ],
    ),
    RouteNode<AccountRoute>(build: (context, account) => const Text('')),
  ]),
);

NavigationPlanner _plannerOver(RouteTree tree) {
  final entryChain = EntryChain(ShellPath(tree));
  final goPlan = GoPlan(tree, entryChain);
  return NavigationPlanner(
    tree,
    entryChain,
    goPlan,
    BranchSwitch(tree, entryChain, goPlan),
    InPlaceUpdate(RoutePages(tree: tree, pageFactory: const TestPageFactory())),
  );
}

/// The shell instance of every entry, bottom to top; `null` on the root.
List<ShellLevel?> shellsOf(TypedRouterState state) => [
  for (final entry in state.entries) entry.levels.firstOrNull,
];

void main() {
  test('the chain of a child of a shell is in one shell instance', () {
    final state = planner.startingAt(user1);

    expect(state.routes, const [UsersRoute(), user1]);
    final [first, second] = shellsOf(state);
    expect(first, isNotNull);
    expect(second, same(first));
  });

  test('go within a shell keeps its instance', () {
    final before = planner.startingAt(user1);

    final after = planner.goTo(before, user2);

    expect(after.routes, const [UsersRoute(), user2]);
    expect(shellsOf(after), everyElement(same(shellsOf(before).first)));
  });

  test('push of a child of the shell on screen joins its instance', () {
    final before = planner.startingAt(user1);

    final after = planner.pushedOnto(before, user2);

    expect(shellsOf(after).last, same(shellsOf(before).first));
  });

  test('push of a route outside the shell goes to the root', () {
    final after = planner.pushedOnto(planner.startingAt(user1), account);

    expect(shellsOf(after).last, isNull);
  });

  test('push of a child of a covered shell starts a new instance', () {
    final covered = planner.pushedOnto(planner.startingAt(user1), account);

    final after = planner.pushedOnto(covered, user2);

    expect(shellsOf(after).last, isNotNull);
    expect(shellsOf(after).last, isNot(same(shellsOf(covered).first)));
  });

  test('replace inside a shell keeps its instance', () {
    final before = planner.startingAt(user1);

    final after = planner.withTopReplaced(before, user2);

    expect(after.routes, const [UsersRoute(), user2]);
    expect(shellsOf(after).last, same(shellsOf(before).first));
  });

  test('a shell without entries is gone', () {
    final state = planner.withoutTop(
      planner.pushedOnto(
        planner.pushedOnto(planner.startingAt(account), user1),
        account,
      ),
    );

    expect(planner.withoutTop(state).toString(), 'AccountRoute()');
  });
}
