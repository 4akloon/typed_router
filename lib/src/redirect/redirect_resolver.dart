import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/redirect/redirect_check.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';

/// The router's own redirect: the route to go to instead of [target], or
/// `null` to let the navigation through.
typedef RouterRedirect = TypedRoute<Object?>? Function(
  BuildContext context,
  NavigationState target,
);

/// Finds where one target is redirected: the router's redirect first, then the
/// nodes of every checked route from the top of the tree down; the first
/// redirect that names another route wins.
final class RedirectResolver {
  /// Creates a resolver over [tree] with the router's optional redirect.
  RedirectResolver({required this._tree, required this._routerRedirect});

  final RouteTree _tree;
  final RouterRedirect? _routerRedirect;

  /// The route [target] is redirected to, or `null`. A redirect returning
  /// the target's top route lets it through, like `null`.
  TypedRoute<Object?>? redirectOf(
    BuildContext context,
    NavigationState target,
    RedirectCheck check,
  ) {
    for (final redirected in _redirects(context, target, check)) {
      if (redirected != null && redirected != target.top) return redirected;
    }
    return null;
  }

  Iterable<TypedRoute<Object?>?> _redirects(
    BuildContext context,
    NavigationState target,
    RedirectCheck check,
  ) sync* {
    if (_routerRedirect case final routerRedirect?) {
      yield routerRedirect(context, target);
    }
    for (final checked in check.routesToCheck(target)) {
      for (final route in _tree.chainTo(checked)) {
        yield _tree.nodeFor(route).redirectFor(context, route, target);
      }
    }
  }
}
