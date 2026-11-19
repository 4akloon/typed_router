import 'package:meta/meta.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/router/typed_router.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';

/// Targets for calling a redirect on its own in a test, as go_router tests
/// build a `GoRouterState`.
///
/// Most redirect tests go through the app: show the router, change the
/// session fake, read [TypedRouter.state]. When a redirect is worth
/// testing on its own, these build the target it receives: the state an
/// operation would build from the current one, with the routes above it
/// from the tree. They run no redirects, commit nothing and work before
/// the router is shown.
///
/// ```dart
/// final target = router.stateAfterPush(const AccountRoute());
/// final context = tester.element(find.byType(HomeScreen));
///
/// expect(
///   appRedirect(context, target),
///   const SignInRoute(returnTo: AccountRoute()),
/// );
/// ```
///
/// Experimental until 1.0: it may change without a major version.
@experimental
extension TypedRouterTargets on TypedRouter {
  /// The state `go(route)` would build from the current state: [route]
  /// with the routes above it. Throws [ArgumentError] when [route]'s type
  /// has no node.
  NavigationState stateAfterGo(TypedRoute<Object?> route) => plannedGo(route);

  /// The state `push(route)` would build: the current stack with [route]
  /// on top. Throws [ArgumentError] when [route]'s type has no node.
  NavigationState stateAfterPush(TypedRoute<Object?> route) =>
      plannedPush(route);
}
