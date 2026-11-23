import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/redirect/redirect_chain.dart';
import 'package:typed_navigator/src/redirect/redirect_check.dart';
import 'package:typed_navigator/src/redirect/redirect_resolver.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/typed_router_state.dart';
import 'package:typed_navigator/src/transaction/navigation_step.dart';

/// Plans the navigation again for the route a redirect named: `go` builds its
/// chain, `push` pushes it.
typedef RedirectedPlan = TypedRouterState Function(TypedRoute<Object?> route);

/// The redirects of one navigation, as a step of its transaction.
///
/// Follows redirects until none fires, re-planning the operation for every new
/// target; whatever a redirect throws, and a [RedirectChainError], fails the
/// transaction, which reports it and keeps the state.
class RedirectStep implements NavigationStep {
  /// Creates the step of one navigation.
  RedirectStep({
    required this._resolver,
    required this._context,
    required this._plan,
    required this._check,
    required this._redirectLimit,
  });

  final RedirectResolver _resolver;
  final BuildContext _context;
  final RedirectedPlan _plan;
  final RedirectCheck _check;
  final int _redirectLimit;

  @override
  TypedRouterState apply(TypedRouterState current, TypedRouterState candidate) {
    final chain = RedirectChain(
      candidate.top,
      redirectLimit: _redirectLimit,
    );
    var target = candidate;
    var check = _check;
    while (true) {
      final next = _resolver.redirectOf(_context, target, check);
      if (next == null) return target;
      chain.follow(next);
      target = _plan(next);
      // The new target's route is the only new one; for a re-check, `go`
      // built the whole stack from it.
      check = const NewRouteCheck();
    }
  }
}
