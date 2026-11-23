import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:typed_navigator/src/router/typed_router.dart';

/// Puts a router above widgets, for `TypedRouter.of` and
/// `TypedRouterState.of`, as go_router's `InheritedGoRouter`.
///
/// The router puts itself above its navigator; an app needs this only to
/// hand its widgets another router, such as a fake one in a widget test.
/// `TypedRouterState.of` then reads `router.state` once and does not
/// rebuild when it changes.
///
/// ```dart
/// await tester.pumpWidget(
///   TypedRouterScope(router: fakeRouter, child: const RoomsScreen()),
/// );
/// ```
class TypedRouterScope extends InheritedWidget {
  /// Puts [router] above [child].
  const TypedRouterScope({
    required this.router,
    required super.child,
    super.key,
  });

  /// The router of this part of the tree.
  final TypedRouter router;

  /// The router above [context], without subscribing [context] to anything;
  /// for `TypedRouter.of`.
  ///
  /// Throws [FlutterError] when there is none.
  @internal
  static TypedRouter routerOf(BuildContext context) {
    if (context.getInheritedWidgetOfExactType<TypedRouterScope>()
        case final scope?) {
      return scope.router;
    }
    throw FlutterError(
      'TypedRouter.of() found no router above this context.\n'
      'Pass the router to MaterialApp.router(routerConfig: router) or '
      'WidgetsApp.router(routerConfig: router), and look it up from a screen '
      'or a dialog of its navigator. Widgets above the navigator, such as '
      'MaterialApp.builder, cannot see it.',
    );
  }

  @override
  bool updateShouldNotify(TypedRouterScope oldWidget) =>
      oldWidget.router != router;
}
