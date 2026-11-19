import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/tree/navigator_slot.dart';
import 'package:typed_navigator/src/tree/nesting.dart';
import 'package:typed_navigator/src/tree/nesting_path.dart';
import 'package:typed_navigator/src/tree/route_placement.dart';
import 'package:typed_navigator/src/tree/route_registry.dart';
import 'package:typed_navigator/src/tree/slot_placement.dart';
import 'package:typed_navigator/src/tree/tabs_validation.dart';
import 'package:typed_navigator/src/tree/tree_node.dart';

/// Walks the nodes of a tree and registers a placement for every route
/// node: its parent link and its [NestingPath].
///
/// Shells, splits and tabs place no route of their own. A shell or a split is
/// transparent: its children sit under the same parent, one level deeper. The
/// children of a branch start their own chains inside that branch's level. A
/// route with a `parentNavigatorSlot` is shown in that slot's navigator, and
/// its children with it.
final class TreeWalk {
  /// Creates a walk that registers into [_registry].
  TreeWalk(this._registry);

  final RouteRegistry _registry;
  final TabsValidation _tabsValidation = const TabsValidation();
  final SlotPlacement _slots = SlotPlacement();

  /// Places [nodes] under [parent], at [path].
  void placeAll(
    Iterable<TreeNode<Object?>> nodes, {
    required RoutePlacement? parent,
    required NestingPath path,
  }) {
    for (final node in nodes) {
      switch (node) {
        case final ShellNode<Object?> shell:
          _placeInside(
            shell,
            'ShellNode',
            ShellNesting(shell),
            shell.children,
            shell.navigatorSlot,
            parent,
            path,
          );
        case final SplitNode<Object?> split:
          _placeInside(
            split,
            'SplitNode',
            SplitNesting(split),
            split.children,
            split.navigatorSlot,
            parent,
            path,
          );
        case final StatefulShellNode tabs:
          _placeTabs(tabs, path);
        case RouteNode() || ParentedRouteNode():
          final placement = _placementFor(node, parent, path);
          _registry.register(placement);
          placeAll(
            placement.node.children,
            parent: placement,
            path: placement.path,
          );
      }
    }
  }

  /// Places [children] of [node], a shell or a split ([nodeName]), one
  /// [nesting] deeper.
  void _placeInside(
    TreeNode<Object?> node,
    String nodeName,
    Nesting nesting,
    List<TreeNode<Object?>> children,
    NavigatorSlot? slot,
    RoutePlacement? parent,
    NestingPath path,
  ) {
    if (children.isEmpty) {
      throw ArgumentError.value(
        node,
        'children',
        'A $nodeName has no children. Give it at least one node.',
      );
    }
    placeAll(
      children,
      parent: parent,
      path: path.inside(nesting, _slots.claimed(slot)),
    );
  }

  void _placeTabs(StatefulShellNode tabs, NestingPath path) {
    _tabsValidation.checkBranches(tabs);
    for (final branch in tabs.branches) {
      final nesting = BranchNesting(tabs, branch.branchType);
      placeAll(
        branch.children,
        parent: null,
        path: path.inside(nesting, _slots.claimed(branch.navigatorSlot)),
      );
      _tabsValidation.checkInitial(branch, nesting, _registry);
    }
  }

  RoutePlacement _placementFor(
    TreeNode<Object?> node,
    RoutePlacement? parent,
    NestingPath path,
  ) => switch ((node, parent)) {
    (final RouteNode<TypedRoute<Object?>> routeNode, _) =>
      RoutePlacement.topLevel(routeNode, path: _slots.placed(routeNode, path)),
    (
      final ParentedRouteNode<TypedRoute<Object?>, TypedRoute<Object?>>
      parentedNode,
      final parent?,
    ) =>
      RoutePlacement.under(
        parentedNode.node,
        parent: parent,
        buildParent: parentedNode.buildParent,
        path: _slots.placed(parentedNode.node, path),
      ),
    _ => throw StateError(
      'A node that places no route, or a node placed with withParent where '
      'no route is above it, reached the placement of routes; the types of '
      'TreeNode and the walk should make this impossible.',
    ),
  };
}
