// Tabs inside tabs: the outer first branch holds the rooms | friends tabs.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import 'operation_fixtures.dart' show rooms;
import 'route_fixtures.dart';
import 'tabs_fixtures.dart';

/// The outer branch holding the rooms | friends tabs.
final class OuterRooms {}

/// The outer branch with the account.
final class OuterAccount {}

/// Outer tabs whose first branch holds the rooms | friends tabs.
List<TreeNode<NoParentRoute>> nestedTabsRoutes(ScreenLog log) => [
  StatefulShellNode(
    builder: (context, state, shell) => shell,
    branches: [
      BranchNode<OuterRooms>(
        initial: rooms,
        children: [tabsRoutes(log).first],
      ),
      BranchNode<OuterAccount>(
        initial: const AccountRoute(),
        children: [
          RouteNode<AccountRoute>(
            build: (context, account) => const Text('Account'),
          ),
        ],
      ),
    ],
  ),
];

/// The shell of the tabs that have [branch].
StatefulShell shellWith(WidgetTester tester, Type branch) => tester
    .widgetList<StatefulShell>(find.byType(StatefulShell, skipOffstage: false))
    .firstWhere((shell) => shell.branches.contains(branch));
