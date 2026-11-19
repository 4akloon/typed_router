import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/tree/route_placement.dart';

// A node without a name is named by its route type (a branch by its type)
// in these messages; type names are readable in debug builds, where these
// errors are met.
// ignore_for_file: avoid_type_to_string

/// Finds where a route type sits in the tree.
///
/// Filled once while the tree is built, then only read.
final class RouteRegistry {
  final Map<Type, RoutePlacement> _placements = {};

  /// Records [placement]; a route type may be placed only once.
  void register(RoutePlacement placement) {
    final routeType = placement.routeType;
    if (_placements.containsKey(routeType)) {
      throw ArgumentError(
        '$routeType has two nodes in the route tree. Each route type has '
        'exactly one node; to show the same screen in another place, '
        'declare a separate route type.',
      );
    }
    _placements[routeType] = placement;
  }

  /// Whether [route]'s type has a node.
  bool hasNodeFor(TypedRoute<Object?> route) =>
      _placements.containsKey(route.runtimeType);

  /// Where [route]'s type sits in the tree.
  RoutePlacement placementOf(TypedRoute<Object?> route) =>
      _placements[route.runtimeType] ??
      (throw ArgumentError(
        '${route.runtimeType} has no node in the route tree. Add a '
        'RouteNode<${route.runtimeType}> to the routes.',
      ));
}
