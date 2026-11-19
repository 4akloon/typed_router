import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/tree/nesting.dart';
import 'package:typed_navigator/src/tree/route_placement.dart';
import 'package:typed_navigator/src/tree/route_registry.dart';
import 'package:typed_navigator/src/tree/tabs_validation.dart';
import 'package:typed_navigator/src/tree/tree_node.dart';

/// Walks the nodes of a tree and registers a placement for every route
/// node: its parent link and the navigator levels around it.
///
/// Shells and tabs place no route of their own. A shell is transparent: its
/// children sit under the same parent, one level deeper. The children of a
/// branch start their own chains inside that branch's level.
final class TreeWalk {
  /// Creates a walk that registers into [_registry].
  TreeWalk(this._registry);

  final RouteRegistry _registry;
  final TabsValidation _tabsValidation = const TabsValidation();

  /// Places [nodes] under [parent], inside [nestings].
  void placeAll(
    Iterable<TreeNode<Object?>> nodes, {
    required RoutePlacement? parent,
    required List<Nesting> nestings,
  }) {
    for (final node in nodes) {
      switch (node) {
        case final ShellNode<Object?> shellNode:
          _placeShell(shellNode, parent, nestings);
        case final StatefulShellNode tabs:
          _placeTabs(tabs, nestings);
        case RouteNode() || ParentedRouteNode():
          final placement = _placementFor(node, parent, nestings);
          _registry.register(placement);
          placeAll(
            placement.node.children,
            parent: placement,
            nestings: nestings,
          );
      }
    }
  }

  void _placeShell(
    ShellNode<Object?> shellNode,
    RoutePlacement? parent,
    List<Nesting> nestings,
  ) {
    if (shellNode.children.isEmpty) {
      throw ArgumentError.value(
        shellNode,
        'children',
        'A ShellNode has no children. Give it at least one node.',
      );
    }
    placeAll(
      shellNode.children,
      parent: parent,
      nestings: List.unmodifiable([
        ...nestings,
        ShellNesting(shellNode),
      ]),
    );
  }

  void _placeTabs(StatefulShellNode tabs, List<Nesting> nestings) {
    _tabsValidation.checkBranches(tabs);
    for (final branch in tabs.branches) {
      final level = BranchNesting(tabs, branch.branchType);
      placeAll(
        branch.children,
        parent: null,
        nestings: List.unmodifiable([...nestings, level]),
      );
      _tabsValidation.checkInitial(branch, level, _registry);
    }
  }

  RoutePlacement _placementFor(
    TreeNode<Object?> node,
    RoutePlacement? parent,
    List<Nesting> nestings,
  ) => switch ((node, parent)) {
    (final RouteNode<TypedRoute<Object?>> routeNode, _) =>
      RoutePlacement.topLevel(routeNode, nestings: nestings),
    (
      final ParentedRouteNode<TypedRoute<Object?>, TypedRoute<Object?>>
      parentedNode,
      final parent?,
    ) =>
      RoutePlacement.under(
        parentedNode.node,
        parent: parent,
        buildParent: parentedNode.buildParent,
        nestings: nestings,
      ),
    _ => throw StateError(
      'A node that places no route, or a node placed with withParent where '
      'no route is above it, reached the placement of routes; the types of '
      'TreeNode and the walk should make this impossible.',
    ),
  };
}
