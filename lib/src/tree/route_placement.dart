import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/tree/nesting.dart';
import 'package:typed_navigator/src/tree/tree_node.dart';

/// Where routes of one type sit in the tree, and how to build the routes
/// above one of them.
final class RoutePlacement {
  /// A placement with no route above it, inside [nestings].
  const RoutePlacement.topLevel(this.node, {this.nestings = const []})
    : _parentLink = null;

  /// A placement under [parent]; [buildParent] makes the parent route from a
  /// route placed here.
  RoutePlacement.under(
    this.node, {
    required RoutePlacement parent,
    required TypedRoute<Object?> Function(TypedRoute<Object?> route)
    buildParent,
    this.nestings = const [],
  }) : _parentLink = _ParentLink(parent, buildParent);

  /// The node that places the routes.
  final RouteNode<TypedRoute<Object?>> node;

  /// The navigator levels around the node in the tree (shells, branches of
  /// tabs), from the outer one in.
  final List<Nesting> nestings;

  final _ParentLink? _parentLink;

  /// The route type placed here.
  Type get routeType => node.routeType;

  /// [route] and the routes above it, outermost first.
  List<TypedRoute<Object?>> chainFor(TypedRoute<Object?> route) =>
      switch (_parentLink) {
        final parentLink? => [...parentLink.chainAbove(route), route],
        null => [route],
      };
}

/// The link from a placement to the one above it.
final class _ParentLink {
  const _ParentLink(this._parent, this._buildParent);

  final RoutePlacement _parent;
  final TypedRoute<Object?> Function(TypedRoute<Object?> route) _buildParent;

  /// The routes above [route], outermost first.
  List<TypedRoute<Object?>> chainAbove(TypedRoute<Object?> route) =>
      _parent.chainFor(_buildParent(route));
}
