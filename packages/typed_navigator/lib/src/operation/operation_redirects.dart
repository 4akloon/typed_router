import 'package:typed_navigator/src/operation/navigation_planner.dart';
import 'package:typed_navigator/src/redirect/redirect_check.dart';
import 'package:typed_navigator/src/redirect/redirect_step.dart';
import 'package:typed_navigator/src/redirect/redirects.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/transaction/navigation_step.dart';

/// The redirects a stack operation runs: those of the route it goes to,
/// re-planning the same operation for a redirect's target; on the error screen,
/// those of the whole stack it leads to, as `refresh` does, so only a stack the
/// redirects let through leaves the error screen.
class OperationRedirects {
  /// Creates the choice over the router's [_redirects]; a redirect of the
  /// whole stack goes to its target with [_planner].
  OperationRedirects(this._redirects, this._planner);

  final Redirects _redirects;
  final NavigationPlanner _planner;

  /// The steps of an operation from [state] that goes to a new route;
  /// [replan] plans the operation again for a redirect's target.
  List<NavigationStep> toNewRoute(
    NavigationState state,
    RedirectedPlan replan,
  ) => state.error == null
      ? _redirects.stepsFor(replan, const NewRouteCheck())
      : ofWholeStack(state);

  /// The steps of an operation from [state] that only removes routes: none,
  /// but the whole stack's on the error screen.
  List<NavigationStep> toRemainingRoutes(NavigationState state) =>
      state.error == null ? const [] : ofWholeStack(state);

  /// The redirects over the whole candidate, as on `refresh`.
  List<NavigationStep> ofWholeStack(NavigationState state) =>
      _redirects.stepsFor(
        (redirected) => _planner.goTo(state, redirected),
        const WholeStackCheck(),
      );
}
