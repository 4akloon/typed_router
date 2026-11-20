import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/operation/branch_switch.dart';
import 'package:typed_navigator/src/operation/entry_chain.dart';
import 'package:typed_navigator/src/operation/go_plan.dart';
import 'package:typed_navigator/src/operation/navigation_planner.dart';
import 'package:typed_navigator/src/operation/shell_path.dart';
import 'package:typed_navigator/src/operation/stack_operations.dart';
import 'package:typed_navigator/src/page/level_pages.dart';
import 'package:typed_navigator/src/page/navigator_pages.dart';
import 'package:typed_navigator/src/page/page_factory.dart';
import 'package:typed_navigator/src/page/route_pages.dart';
import 'package:typed_navigator/src/redirect/redirect_resolver.dart';
import 'package:typed_navigator/src/redirect/redirects.dart';
import 'package:typed_navigator/src/redirect/router_mount.dart';
import 'package:typed_navigator/src/redirect/stack_recheck.dart';
import 'package:typed_navigator/src/result/result_completion.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/router/current_navigators.dart';
import 'package:typed_navigator/src/tabs/tabs_switching.dart';
import 'package:typed_navigator/src/transaction/entry_lifecycles.dart';
import 'package:typed_navigator/src/transaction/navigation_controller.dart';
import 'package:typed_navigator/src/transaction/retired_navigators.dart';
import 'package:typed_navigator/src/tree/no_parent_route.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';
import 'package:typed_navigator/src/tree/tree_node.dart';

/// The collaborators of one `TypedRouter`, wired from its constructor's
/// arguments, so the router itself only delegates.
///
/// Validates while wiring: the tree, the initial route and the redirect limit
/// throw [ArgumentError] here.
final class RouterParts {
  /// Wires the collaborators of a router; see `TypedRouter.new` for the
  /// arguments.
  factory RouterParts({
    required List<TreeNode<NoParentRoute>> routes,
    required TypedRoute<Object?> initialRoute,
    required PageFactory pageFactory,
    required RouterRedirect? redirect,
    required int redirectLimit,
    required Widget Function(BuildContext context, Object error)? errorBuilder,
  }) {
    final tree = RouteTree(routes);
    final mount = RouterMount();
    final redirects = Redirects(
      resolver: RedirectResolver(tree: tree, routerRedirect: redirect),
      mount: mount,
      redirectLimit: redirectLimit,
    );
    final entryChain = EntryChain(ShellPath(tree));
    final planner = NavigationPlanner(
      tree,
      entryChain,
      GoPlan(tree, entryChain),
      BranchSwitch(tree, entryChain),
    );
    final controller = NavigationController(
      initialState: planner.startingAt(initialRoute),
      entryLifecycle: const EntryLifecycles([
        ResultCompletion(),
        RetiredNavigators(),
      ]),
    );
    final operations = StackOperations(controller, planner, redirects);
    final routePages = RoutePages(tree: tree, pageFactory: pageFactory);
    return RouterParts._(
      controller: controller,
      operations: operations,
      recheck: StackRecheck(controller, planner, redirects),
      pages: NavigatorPages(
        routePages: routePages,
        levelPages: LevelPages(
          routePages: routePages,
          pageFactory: pageFactory,
          switchingFor: (tabs) => TabsSwitching(operations, tabs),
          currentNavigators: const CurrentNavigators(),
        ),
        pageFactory: pageFactory,
        errorBuilder: errorBuilder,
      ),
      mount: mount,
    );
  }

  RouterParts._({
    required this.controller,
    required this.operations,
    required this.recheck,
    required this.pages,
    required this.mount,
  });

  /// Owns the state.
  final NavigationController controller;

  /// Carries out `go`, `push`, `pop` and the rest.
  final StackOperations operations;

  /// Runs the redirects over the whole stack.
  final StackRecheck recheck;

  /// Turns the state into the navigator's pages.
  final NavigatorPages pages;

  /// Whether the router is shown.
  final RouterMount mount;
}
