import 'package:typed_router/src/route/typed_route.dart';
import 'package:typed_router/src/tree/nesting.dart';
import 'package:typed_router/src/tree/nesting_path.dart';
import 'package:typed_router/src/tree/no_parent_route.dart';
import 'package:typed_router/src/tree/route_registry.dart';
import 'package:typed_router/src/tree/tree_node.dart';
import 'package:typed_router/src/tree/tree_walk.dart';

/// The validated route tree: knows where every route type sits and which
/// routes lie below a route on the stack.
///
/// Internal: the router builds it from its `routes`.
class RouteTree {
  /// Places every node of [roots] and their descendants.
  ///
  /// Throws [ArgumentError] when [roots] is empty, a route type has two
  /// nodes, or a shell or tabs node is malformed.
  RouteTree(List<TreeNode<NoParentRoute>> roots) {
    if (roots.isEmpty) {
      throw ArgumentError.value(
        roots,
        'roots',
        'The route tree has no nodes. Pass at least one RouteNode.',
      );
    }
    TreeWalk(
      _registry,
    ).placeAll(roots, parent: null, path: const NestingPath.top());
  }

  final RouteRegistry _registry = RouteRegistry();

  /// [route] and the routes above it, outermost first:
  /// `RoomRoute(7)` → `[RoomsRoute(), RoomRoute(7)]`.
  ///
  /// Throws [ArgumentError] when [route]'s type has no node.
  List<TypedRoute<Object?>> chainTo(TypedRoute<Object?> route) =>
      _registry.placementOf(route).chainFor(route);

  /// The shells and branches [route] is shown in, outer first; empty for a
  /// route of the root navigator.
  ///
  /// Throws [ArgumentError] when [route]'s type has no node.
  List<Nesting> nestingsOf(TypedRoute<Object?> route) =>
      _registry.placementOf(route).nestings;

  /// The shells and branches around [route]'s node in the tree, outer first:
  /// their redirects guard it, wherever it is shown.
  ///
  /// Throws [ArgumentError] when [route]'s type has no node.
  List<Nesting> guardingNestingsOf(TypedRoute<Object?> route) =>
      _registry.placementOf(route).guardingNestings;

  /// Throws [ArgumentError] when [route]'s type has no node, so nothing can
  /// show it.
  void ensurePlaced(TypedRoute<Object?> route) => _registry.placementOf(route);

  /// The node of [route]'s type.
  ///
  /// Throws [ArgumentError] when [route]'s type has no node.
  RouteNode<TypedRoute<Object?>> nodeFor(TypedRoute<Object?> route) =>
      _registry.placementOf(route).node;
}
