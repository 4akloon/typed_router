import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/tree/no_parent_route.dart';
import 'package:typed_navigator/src/tree/route_placement.dart';
import 'package:typed_navigator/src/tree/route_registry.dart';
import 'package:typed_navigator/src/tree/tree_node.dart';

/// The validated route tree: knows where every route type sits and which
/// routes lie below a route on the stack.
///
/// Internal: the router builds it from its `routes`.
final class RouteTree {
  /// Places every node of [roots] and their descendants.
  ///
  /// Throws [ArgumentError] when [roots] is empty or a route type has two
  /// nodes.
  RouteTree(List<TreeNode<NoParentRoute>> roots) {
    if (roots.isEmpty) {
      throw ArgumentError.value(
        roots,
        'roots',
        'The route tree has no nodes. Pass at least one RouteNode.',
      );
    }
    _placeAll(roots, parent: null, shellNodes: const []);
  }

  final RouteRegistry _registry = RouteRegistry();

  /// [route] and the routes above it, outermost first:
  /// `RoomRoute(7)` → `[RoomsRoute(), RoomRoute(7)]`.
  ///
  /// Throws [ArgumentError] when [route]'s type has no node.
  List<TypedRoute<Object?>> chainTo(TypedRoute<Object?> route) =>
      _registry.placementOf(route).chainFor(route);

  /// The shells around [route]'s node, from the outer one in; empty for a
  /// route of the root navigator.
  ///
  /// Throws [ArgumentError] when [route]'s type has no node.
  List<ShellNode<Object?>> shellNodesOf(TypedRoute<Object?> route) =>
      _registry.placementOf(route).shellNodes;

  /// Throws [ArgumentError] when [route]'s type has no node, so nothing can
  /// show it.
  void ensurePlaced(TypedRoute<Object?> route) => _registry.placementOf(route);

  /// The node of [route]'s type.
  ///
  /// Throws [ArgumentError] when [route]'s type has no node.
  RouteNode<TypedRoute<Object?>> nodeFor(TypedRoute<Object?> route) =>
      _registry.placementOf(route).node;

  void _placeAll(
    Iterable<TreeNode<Object?>> nodes, {
    required RoutePlacement? parent,
    required List<ShellNode<Object?>> shellNodes,
  }) {
    for (final node in nodes) {
      if (node case final ShellNode<Object?> shellNode) {
        _placeShell(shellNode, parent: parent, shellNodes: shellNodes);
        continue;
      }
      final placement = _placementFor(node, parent, shellNodes);
      _registry.register(placement);
      _placeAll(
        placement.node.children,
        parent: placement,
        shellNodes: shellNodes,
      );
    }
  }

  /// A shell is transparent: its children sit under the same parent, one shell
  /// deeper.
  void _placeShell(
    ShellNode<Object?> shellNode, {
    required RoutePlacement? parent,
    required List<ShellNode<Object?>> shellNodes,
  }) {
    if (shellNode.children.isEmpty) {
      throw ArgumentError.value(
        shellNode,
        'children',
        'A ShellNode has no children. Give it at least one node.',
      );
    }
    _placeAll(
      shellNode.children,
      parent: parent,
      shellNodes: List.unmodifiable([...shellNodes, shellNode]),
    );
  }

  RoutePlacement _placementFor(
    TreeNode<Object?> node,
    RoutePlacement? parent,
    List<ShellNode<Object?>> shellNodes,
  ) => switch ((node, parent)) {
    (ShellNode(), _) => throw StateError(
      'A ShellNode reached the placement of routes; _placeAll places it.',
    ),
    (final RouteNode<TypedRoute<Object?>> routeNode, _) =>
      RoutePlacement.topLevel(routeNode, shellNodes: shellNodes),
    (
      final ParentedRouteNode<TypedRoute<Object?>, TypedRoute<Object?>>
      parentedNode,
      final parent?,
    ) =>
      RoutePlacement.under(
        parentedNode.node,
        parent: parent,
        buildParent: parentedNode.buildParent,
        shellNodes: shellNodes,
      ),
    (ParentedRouteNode(), null) => throw StateError(
      'A node placed with withParent was found where no route is above it; '
      'the types of TreeNode should make this impossible.',
    ),
  };
}
