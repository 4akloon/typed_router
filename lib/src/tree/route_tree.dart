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
    _placeAll(roots, parent: null);
  }

  final RouteRegistry _registry = RouteRegistry();

  /// [route] and the routes above it, outermost first:
  /// `RoomRoute(7)` → `[RoomsRoute(), RoomRoute(7)]`.
  ///
  /// Throws [ArgumentError] when [route]'s type has no node.
  List<TypedRoute<Object?>> chainTo(TypedRoute<Object?> route) =>
      _registry.placementOf(route).chainFor(route);

  void _placeAll(
    Iterable<TreeNode<Object?>> nodes, {
    required RoutePlacement? parent,
  }) {
    for (final node in nodes) {
      final placement = _placementFor(node, parent);
      _registry.register(placement);
      _placeAll(placement.node.children, parent: placement);
    }
  }

  RoutePlacement _placementFor(
    TreeNode<Object?> node,
    RoutePlacement? parent,
  ) => switch ((node, parent)) {
    (final RouteNode<TypedRoute<Object?>> routeNode, _) =>
      RoutePlacement.topLevel(routeNode),
    (
      final ParentedRouteNode<TypedRoute<Object?>, TypedRoute<Object?>>
      parentedNode,
      final parent?,
    ) =>
      RoutePlacement.under(
        parentedNode.node,
        parent: parent,
        buildParent: parentedNode.buildParent,
      ),
    (ParentedRouteNode(), null) => throw StateError(
      'A node placed with withParent was found where no route is above it; '
      'the types of TreeNode should make this impossible.',
    ),
  };
}
