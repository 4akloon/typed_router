import 'package:typed_router/src/route/typed_route.dart';
import 'package:typed_router/src/tree/navigator_slot.dart';
import 'package:typed_router/src/tree/nesting.dart';
import 'package:typed_router/src/tree/nesting_path.dart';
import 'package:typed_router/src/tree/route_placement.dart';
import 'package:typed_router/src/tree/route_registry.dart';
import 'package:typed_router/src/tree/slot_placement.dart';
import 'package:typed_router/src/tree/tabs_validation.dart';
import 'package:typed_router/src/tree/tree_node.dart';

// A node without a name is named by its route type (a branch by its type)
// in these messages; type names are readable in debug builds, where these
// errors are met.
// ignore_for_file: avoid_type_to_string

/// Walks the nodes of a tree and registers a placement for every route
/// node: its parent link and its [NestingPath].
///
/// Shells and tabs place no route of their own. A shell is transparent: its
/// children sit under the same parent, one level deeper. The children of a
/// branch start their own chains inside that branch's level. A route with a
/// `parentNavigatorSlot` is shown in that slot's navigator, and its children
/// with it.
class TreeWalk {
  /// Creates a walk that registers into [_registry].
  TreeWalk(this._registry);

  final RouteRegistry _registry;
  final TabsValidation _tabsValidation = const TabsValidation();
  final SlotPlacement _slotPlacement = const SlotPlacement();
  final Set<NavigatorSlot> _usedSlots = {NavigatorSlot.root};

  /// Places [nodes] under [parent], at [path].
  void placeAll(
    Iterable<TreeNode<Object?>> nodes, {
    required RoutePlacement? parent,
    required NestingPath path,
  }) {
    for (final node in nodes) {
      switch (node) {
        case final ShellNode<Object?> shellNode:
          _placeShell(shellNode, parent, path);
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

  void _placeShell(
    ShellNode<Object?> shellNode,
    RoutePlacement? parent,
    NestingPath path,
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
      path: path.inside(
        ShellNesting(shellNode),
        _claimed(shellNode.navigatorSlot),
      ),
    );
  }

  void _placeTabs(StatefulShellNode tabs, NestingPath path) {
    _tabsValidation.checkBranches(tabs);
    for (final branch in tabs.branches) {
      final nesting = BranchNesting(tabs, branch.branchType);
      placeAll(
        branch.children,
        parent: null,
        path: path.inside(nesting, _claimed(branch.navigatorSlot)),
      );
      _tabsValidation.checkInitial(branch, nesting, _registry);
    }
  }

  /// [slot], once: a slot names one shell or branch.
  NavigatorSlot? _claimed(NavigatorSlot? slot) {
    if (slot != null && !_usedSlots.add(slot)) {
      throw ArgumentError(
        'A NavigatorSlot is given to two shells or branches. Give each its '
        'own slot.',
      );
    }
    return slot;
  }

  RoutePlacement _placementFor(
    TreeNode<Object?> node,
    RoutePlacement? parent,
    NestingPath path,
  ) => switch ((node, parent)) {
    (final RouteNode<TypedRoute<Object?>> routeNode, _) =>
      RoutePlacement.topLevel(
        routeNode,
        path: _slotPlacement.placed(routeNode, path),
      ),
    (
      final ParentedRouteNode<TypedRoute<Object?>, TypedRoute<Object?>>
      parentedNode,
      final parent?,
    ) =>
      RoutePlacement.under(
        parentedNode.node,
        parent: parent,
        buildParent: parentedNode.buildParent,
        path: _slotPlacement.placed(parentedNode.node, path),
      ),
    // WithParent((route) => throw...) infers Never, and a TreeNode<Never> fits
    // where no route is above.
    (
      final ParentedRouteNode<TypedRoute<Object?>, TypedRoute<Object?>>
      parentedNode,
      null,
    ) =>
      throw ArgumentError(
        '${parentedNode.node.name ?? parentedNode.node.routeType} is placed '
        'with withParent where no route is above it: its withParent builds '
        'Never (a closure that only throws). Name the parent type, '
        'withParent<ParentRoute>(...), or drop withParent.',
      ),
    _ => throw StateError(
      'A node that places no route reached the placement of routes; the '
      'types of TreeNode and the walk should make this impossible.',
    ),
  };
}
