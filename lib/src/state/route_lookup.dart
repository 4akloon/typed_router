import 'package:typed_navigator/src/route/typed_route.dart';

/// Finds routes on the active path for `NavigationState`.
final class RouteLookup {
  /// Creates the lookup over [_routes], bottom to top.
  const RouteLookup(this._routes);

  final List<TypedRoute<Object?>> _routes;

  /// The route of type [R] nearest to the top, or `null`.
  R? find<R extends TypedRoute<Object?>>() {
    for (final route in _routes.reversed) {
      if (route case final R match) return match;
    }
    return null;
  }

  /// Whether a route is a [T].
  bool contains<T>() => _routes.any((route) => route is T);

  /// The route right above the last route equal to [route], or `null`.
  TypedRoute<Object?>? after(TypedRoute<Object?> route) {
    final index = _routes.lastIndexOf(route);
    return index < 0 || index == _routes.length - 1 ? null : _routes[index + 1];
  }
}
