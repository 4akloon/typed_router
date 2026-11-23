import 'package:typed_router/src/state/typed_router_state.dart';
import 'package:typed_router/src/transaction/navigation_step.dart';

/// Runs a navigation candidate through the steps of that navigation, in
/// order.
///
/// Knows whether it is running, so that a navigation started from inside a step
/// can be rejected. The steps belong to one navigation, not to the transaction.
class NavigationTransaction {
  bool _isRunning = false;

  /// Whether a step is being applied right now.
  bool get isRunning => _isRunning;

  /// Returns the state [steps] settle on, starting from [candidate].
  ///
  /// Whatever a step throws propagates to the caller.
  TypedRouterState run(
    TypedRouterState current,
    TypedRouterState candidate,
    List<NavigationStep> steps,
  ) {
    _isRunning = true;
    try {
      return steps.fold(candidate, (state, step) => step.apply(current, state));
    } finally {
      _isRunning = false;
    }
  }
}
