import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/transaction/navigation_step.dart';

/// Runs a navigation candidate through the steps, in order.
///
/// Knows whether it is running, so that a navigation started from inside a
/// step can be rejected.
final class NavigationTransaction {
  /// Creates a transaction over [steps], applied in the given order.
  NavigationTransaction(List<NavigationStep> steps)
    : _steps = List.unmodifiable(steps);

  final List<NavigationStep> _steps;
  bool _isRunning = false;

  /// Whether a step is being applied right now.
  bool get isRunning => _isRunning;

  /// Returns the state the steps settle on, starting from [candidate].
  ///
  /// Whatever a step throws propagates to the caller.
  NavigationState run(NavigationState current, NavigationState candidate) {
    _isRunning = true;
    try {
      return _steps.fold(
        candidate,
        (state, step) => step.apply(current, state),
      );
    } finally {
      _isRunning = false;
    }
  }
}
