import 'package:typed_router/src/redirect/redirect_check.dart';
import 'package:typed_router/src/redirect/redirect_resolver.dart';
import 'package:typed_router/src/redirect/redirect_step.dart';
import 'package:typed_router/src/redirect/router_mount.dart';
import 'package:typed_router/src/transaction/navigation_step.dart';

/// The redirects of a router: gives each navigation its redirect step while the
/// router is shown.
class Redirects {
  /// Creates the redirects of a router; throws [ArgumentError] when
  /// [redirectLimit] is negative.
  Redirects({
    required this._resolver,
    required this._mount,
    required int redirectLimit,
  }) : _redirectLimit = redirectLimit {
    if (redirectLimit < 0) {
      throw ArgumentError.value(
        redirectLimit,
        'redirectLimit',
        'redirectLimit must be 0 or more, got $redirectLimit.',
      );
    }
  }

  final RedirectResolver _resolver;
  final RouterMount _mount;
  final int _redirectLimit;

  /// The steps of one navigation: a redirect step that re-plans with
  /// [plan] and starts with [check], or none while the router is not shown.
  List<NavigationStep> stepsFor(RedirectedPlan plan, RedirectCheck check) =>
      switch (_mount.context) {
        final context? => [
          RedirectStep(
            resolver: _resolver,
            context: context,
            plan: plan,
            check: check,
            redirectLimit: _redirectLimit,
          ),
        ],
        null => const [],
      };
}
