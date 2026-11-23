import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';

/// Puts the router's state above its navigator, so a screen that reads it with
/// `NavigationState.of` rebuilds on every navigation. Next to
/// `TypedRouterScope`, which holds the router itself and does not change when
/// the state does.
class NavigationStateScope extends InheritedWidget {
  /// Puts [state] above [child].
  const NavigationStateScope({
    required this.state,
    required super.child,
    super.key,
  });

  /// The router's state.
  final NavigationState state;

  /// The state above [context], which rebuilds when it changes.
  ///
  /// Throws [FlutterError] when there is none.
  static NavigationState stateOf(BuildContext context) {
    if (context.dependOnInheritedWidgetOfExactType<NavigationStateScope>()
        case final scope?) {
      return scope.state;
    }
    throw FlutterError(
      'NavigationState.of() found no router above this context.\n'
      'Pass the router to MaterialApp.router(routerConfig: router) or '
      'WidgetsApp.router(routerConfig: router), and read the state from a '
      'screen or a dialog of its navigator.',
    );
  }

  @override
  bool updateShouldNotify(NavigationStateScope oldWidget) =>
      oldWidget.state != state;
}
