import 'package:typed_navigator/src/state/navigation_state.dart';

/// One stage of a navigation transaction: looks at the candidate state and
/// returns the state to continue with.
///
/// Steps run synchronously, in order, before the state is committed. A step
/// returns [candidate] to let the navigation through, or another state to
/// replace it (a redirect). A step never navigates by itself: calling the
/// router from inside a step is an error in debug.
abstract interface class NavigationStep {
  /// Returns the state to continue with, given the [current] committed
  /// state and the [candidate] produced so far.
  NavigationState apply(NavigationState current, NavigationState candidate);
}
