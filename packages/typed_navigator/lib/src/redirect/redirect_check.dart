import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/typed_router_state.dart';

/// Which routes of a target the redirects of the nodes look at. The router's
/// own redirect always sees the whole target.
sealed class RedirectCheck {
  const RedirectCheck();

  /// The routes of [target] whose nodes, and their ancestors' nodes, run
  /// their redirects, bottom to top.
  List<TypedRoute<Object?>> routesToCheck(TypedRouterState target);
}

/// An operation: only the route it goes to, with its ancestors. The routes
/// below were checked when they were opened.
class NewRouteCheck extends RedirectCheck {
  /// Creates the check of an operation's route.
  const NewRouteCheck();

  @override
  List<TypedRoute<Object?>> routesToCheck(TypedRouterState target) => [
    target.top,
  ];
}

/// Showing the router or re-checking it: every route on the stack, since
/// any of them may have become forbidden.
class WholeStackCheck extends RedirectCheck {
  /// Creates the check of the whole stack.
  const WholeStackCheck();

  @override
  List<TypedRoute<Object?>> routesToCheck(TypedRouterState target) =>
      target.routes;
}
