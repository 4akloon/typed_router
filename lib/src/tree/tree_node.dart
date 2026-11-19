import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/tree/no_parent_route.dart';

// TreeNode is sealed, so its variants live in this library. The functions a
// node holds are only called from the node's own methods, where the route
// type is known: read through a wider type they would fail Dart's covariance
// check at runtime.

/// A node of the route tree, declared top-down.
///
/// [P] is the type of the route directly above the node. A node that needs
/// nothing from above is a `TreeNode<NoParentRoute>`; a node that builds its
/// parent route ([RouteNode.withParent]) is a `TreeNode<ThatParentRoute>`, so
/// the compiler only lets it sit under that parent.
sealed class TreeNode<P> {
  const TreeNode();
}

/// Places routes of type [R] in the tree and builds their screen.
///
/// A route type has exactly one node. To show the same screen in another
/// place, declare a separate route type.
///
/// ```dart
/// final List<TreeNode<NoParentRoute>> roomsRoutes = [
///   RouteNode<RoomsRoute>(
///     build: (context, route) => const RoomsPage(),
///     children: [
///       RouteNode<RoomRoute>(
///         build: (context, room) => RoomPage(roomId: room.id),
///       ).withParent((_) => const RoomsRoute()),
///     ],
///   ),
/// ];
/// ```
final class RouteNode<R extends TypedRoute<Object?>>
    extends TreeNode<NoParentRoute> {
  /// Creates a node for routes of type [R].
  const RouteNode({required this.build, this.children = const []});

  /// Builds the screen for a route of type [R].
  final Widget Function(BuildContext context, R route) build;

  /// Nodes under this one. Each of them is put here with [withParent], so it
  /// can build an [R] for the stack below itself.
  final List<TreeNode<R>> children;

  /// This node under a parent it builds itself from its own route.
  ///
  /// [P] comes from the `children` list the result is put in, so [parent]
  /// must return exactly that parent's route: a wrong type, the wrong place
  /// or the top level do not compile.
  TreeNode<P> withParent<P extends TypedRoute<Object?>>(
    P Function(R route) parent,
  ) => ParentedRouteNode<P, R>(this, parent);

  /// The route type this node places.
  @internal
  Type get routeType => R;
}

/// A [RouteNode] put under a parent route with [RouteNode.withParent].
///
/// Not exported: users only ever see it as a `TreeNode<P>`.
final class ParentedRouteNode<
  P extends TypedRoute<Object?>,
  R extends TypedRoute<Object?>
>
    extends TreeNode<P> {
  /// Wraps [node] with the function that builds its parent route.
  const ParentedRouteNode(this.node, this._buildParent);

  /// The node placed under the parent.
  final RouteNode<R> node;

  final P Function(R route) _buildParent;

  /// Builds the parent route of [route], which is always an [R].
  TypedRoute<Object?> buildParent(TypedRoute<Object?> route) =>
      _buildParent(route as R);
}
