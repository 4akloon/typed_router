import 'package:typed_navigator/src/operation/navigation_planner.dart';
import 'package:typed_navigator/src/result/pending_result.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/transaction/navigation_controller.dart';

/// Carries out the router's stack operations: checks what must hold
/// before, asks the planner for the candidate and hands it to the
/// controller.
final class StackOperations {
  /// Creates operations that plan with [_planner] and commit through
  /// [_controller].
  StackOperations(this._controller, this._planner);

  final NavigationController _controller;
  final NavigationPlanner _planner;

  NavigationState get _state => _controller.state;

  /// Whether [pop] can remove an entry.
  bool get canPop => _state.entries.length > 1;

  /// See `TypedRouter.go`.
  void go(TypedRoute<Object?> route) =>
      _controller.navigate(_planner.goTo(_state, route));

  /// See `TypedRouter.push`.
  Future<T?> push<T>(TypedRoute<T> route) =>
      _navigateWithNew(route, (entry) => _planner.pushedOnto(_state, entry));

  /// See `TypedRouter.pop`.
  void pop(Object? result) {
    if (!canPop) {
      throw StateError(
        'Nothing to pop: the stack has one entry. Check canPop or use go.',
      );
    }
    final top = _state.entries.last..checkResult(result);
    top.recordResult(result);
    _controller.navigate(_planner.withoutTop(_state));
  }

  /// See `TypedRouter.popUntil`.
  void popUntil(RoutePredicate predicate) =>
      _controller.navigate(_planner.poppedUntil(_state, predicate));

  /// See `TypedRouter.replace`.
  Future<T?> replace<T>(TypedRoute<T> route) => _navigateWithNew(
    route,
    (entry) => _planner.withTopReplaced(_state, entry),
  );

  /// See `TypedRouter.pushAndRemoveUntil`.
  Future<T?> pushAndRemoveUntil<T>(
    TypedRoute<T> route,
    RoutePredicate predicate,
  ) => _navigateWithNew(
    route,
    (entry) => _planner.pushedAfterPoppingUntil(_state, entry, predicate),
  );

  /// Navigates to the candidate [plan] builds around a new entry for
  /// [route]. An entry that does not reach the committed state (a step
  /// redirected or failed) leaves at once: its push completes with `null`.
  Future<T?> _navigateWithNew<T>(
    TypedRoute<T> route,
    NavigationState Function(NavigationEntry entry) plan,
  ) {
    final pendingResult = PendingResult<T>();
    final entry = NavigationEntry(route, pendingResult: pendingResult);
    _controller.navigate(plan(entry));
    if (!_state.entries.contains(entry)) entry.leave();
    return pendingResult.future;
  }
}
