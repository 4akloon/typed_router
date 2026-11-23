import 'package:typed_router/src/route/typed_route.dart';
import 'package:typed_router/src/tree/nesting.dart';
import 'package:typed_router/src/tree/nesting_path.dart';
import 'package:typed_router/src/tree/tree_node.dart';

/// Where routes of one type sit in the tree, and how to build the routes
/// above one of them.
class RoutePlacement {
  /// A placement with no route above it, at [path].
  RoutePlacement.topLevel(this.node, {required this.path}) : _parentLink = null;

  /// A placement under [parent]; [buildParent] makes the parent route from a
  /// route placed here.
  RoutePlacement.under(
    this.node, {
    required RoutePlacement parent,
    required TypedRoute<Object?> Function(TypedRoute<Object?> route)
    buildParent,
    required this.path,
  }) : _parentLink = _ParentLink(parent, buildParent);

  /// The node that places the routes.
  final RouteNode<TypedRoute<Object?>> node;

  /// Where the node sits: the nesting its routes are shown in, and the one
  /// around it in the tree.
  final NestingPath path;

  /// The shells and branches the routes are shown in, outer first.
  List<Nesting> get nestings => path.shown;

  /// The shells and branches around the node in the tree, outer first: their
  /// redirects guard the routes.
  List<Nesting> get guardingNestings => path.guarding;

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
class _ParentLink {
  const _ParentLink(this._parent, this._buildParent);

  final RoutePlacement _parent;
  final TypedRoute<Object?> Function(TypedRoute<Object?> route) _buildParent;

  /// The routes above [route], outermost first.
  List<TypedRoute<Object?>> chainAbove(TypedRoute<Object?> route) =>
      _parent.chainFor(_buildParent(route));
}
