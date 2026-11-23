import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/router/typed_router_scope.dart';
import 'package:typed_navigator/src/state/typed_router_state.dart';

/// Puts the router's state above its navigator, so a screen that reads it with
/// `TypedRouterState.of` rebuilds on every navigation. Next to
/// `TypedRouterScope`, which holds the router itself and does not change when
/// the state does.
class TypedRouterStateScope extends InheritedWidget {
  /// Puts [state] above [child].
  const TypedRouterStateScope({
    required this.state,
    required super.child,
    super.key,
  });

  /// The router's state.
  final TypedRouterState state;

  /// The state above [context], which rebuilds when it changes; without one,
  /// the state of a router an app put above with `TypedRouterScope`, read once.
  ///
  /// Throws [FlutterError] when there is none.
  static TypedRouterState stateOf(BuildContext context) {
    if (context.dependOnInheritedWidgetOfExactType<TypedRouterStateScope>()
        case final scope?) {
      return scope.state;
    }
    if (context.getInheritedWidgetOfExactType<TypedRouterScope>()
        case final routerScope?) {
      return routerScope.router.state;
    }
    throw FlutterError(
      'TypedRouterState.of() found no router above this context.\n'
      'Pass the router to MaterialApp.router(routerConfig: router) or '
      'WidgetsApp.router(routerConfig: router), and read the state from a '
      'screen or a dialog of its navigator.',
    );
  }

  @override
  bool updateShouldNotify(TypedRouterStateScope oldWidget) =>
      oldWidget.state != state;
}
