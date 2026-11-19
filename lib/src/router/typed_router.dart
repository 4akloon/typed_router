import 'package:flutter/foundation.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/transaction/navigation_controller.dart';
import 'package:typed_navigator/src/tree/no_parent_route.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';
import 'package:typed_navigator/src/tree/tree_node.dart';

/// The application's router: owns the route tree and the current
/// [NavigationState], and notifies listeners when the state changes.
///
/// Create it once, before `runApp`, and keep it where the app keeps its
/// dependencies: a top-level `final`, a DI container, a field of the app
/// widget's state. The library has no global access to routers; several
/// independent routers can live in one process, even over the same nodes.
///
/// The creator owns the router and calls [dispose] when it is no longer
/// needed; widgets never dispose it.
///
/// ```dart
/// final router = TypedRouter(
///   routes: [
///     RouteNode<RoomsRoute>(
///       build: (context, route) => const RoomsScreen(),
///       children: [
///         RouteNode<RoomRoute>(
///           build: (context, route) => RoomScreen(id: route.id),
///         ).withParent((room) => const RoomsRoute()),
///       ],
///     ),
///   ],
///   initialRoute: const RoomsRoute(),
/// );
/// ```
final class TypedRouter implements Listenable {
  /// Creates a router over the tree of [routes] that starts at
  /// [initialRoute], with the routes above it built from the tree.
  ///
  /// Needs no widgets binding. Throws [ArgumentError] when [routes] is
  /// empty, a route type has two nodes, or [initialRoute]'s type has no
  /// node.
  factory TypedRouter({
    required List<TreeNode<NoParentRoute>> routes,
    required TypedRoute<Object?> initialRoute,
  }) {
    final tree = RouteTree(routes);
    final initialState = NavigationState.fromEntries([
      for (final route in tree.chainTo(initialRoute)) NavigationEntry(route),
    ]);
    return TypedRouter._(NavigationController(initialState: initialState));
  }

  TypedRouter._(this._controller);

  final NavigationController _controller;

  /// What is on screen now. Starts at the initial route and its ancestors;
  /// stays readable after [dispose].
  NavigationState get state => _controller.state;

  /// Calls [listener] after every navigation that changes [state].
  ///
  /// Throws [StateError] after [dispose].
  @override
  void addListener(VoidCallback listener) => _controller.addListener(listener);

  /// Stops calling [listener]. Allowed after [dispose], so a widget can
  /// clean up after the router is gone.
  @override
  void removeListener(VoidCallback listener) =>
      _controller.removeListener(listener);

  /// Releases the router: drops the listeners and ends every route on the
  /// stack.
  ///
  /// [state] stays readable; adding a listener, navigating or disposing
  /// again throws [StateError].
  void dispose() => _controller.dispose();

  /// `TypedRouter(RoomsRoute() > RoomRoute(RoomId(7)))`, for logs and test
  /// failures.
  @override
  String toString() => 'TypedRouter($state)';
}
