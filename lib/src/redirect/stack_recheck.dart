import 'package:typed_navigator/src/operation/navigation_planner.dart';
import 'package:typed_navigator/src/redirect/redirect_check.dart';
import 'package:typed_navigator/src/redirect/redirects.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/transaction/navigation_controller.dart';
import 'package:typed_navigator/src/transaction/transaction_outcome.dart';

/// Runs the redirects over the whole stack: when the router is shown, when an
/// inherited widget a redirect depends on changes, on `refreshListenable` and
/// `TypedRouter.refresh`.
///
/// A redirect replaces the stack with its target's chain (`go`). A failure
/// leaves no safe state to stay on, so the stack is kept with the error and the
/// navigator shows the error screen. Does nothing while the router is not
/// shown.
final class StackRecheck {
  /// Creates the re-check of the stack [_controller] holds.
  StackRecheck(this._controller, this._planner, this._redirects);

  final NavigationController _controller;
  final NavigationPlanner _planner;
  final Redirects _redirects;

  NavigationState get _state => _controller.state;

  /// Re-checks outside a build: listeners hear about a change at once.
  void recheck() => _recheck();

  /// Re-checks while the router's widgets build (shown for the first time,
  /// a dependency changed): listeners hear about it after the frame.
  void recheckWhileBuilding() => _controller.changeWhileBuilding(_recheck);

  void _recheck() {
    final steps = _redirects.stepsFor(
      (redirected) => _planner.goTo(_state, redirected),
      const WholeStackCheck(),
    );
    if (steps.isEmpty) return;
    // A stack shown with an error is checked as it is, so it comes back
    // once the redirects let it through.
    final candidate = NavigationState.fromEntries(_state.entries);
    final outcome = _controller.navigate(candidate, steps: steps);
    if (outcome case TransactionFailed(:final error)) {
      _controller.applyExternalChange(_state.withError(error));
    }
  }
}
