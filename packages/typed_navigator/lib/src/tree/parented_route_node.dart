part of 'tree_node.dart';

/// A [RouteNode] put under a parent route with [RouteNode.withParent].
///
/// Not exported: users only ever see it as a `TreeNode<P>`.
class ParentedRouteNode<
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
