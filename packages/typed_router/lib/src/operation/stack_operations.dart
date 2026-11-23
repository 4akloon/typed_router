import 'package:typed_router/src/operation/navigation_planner.dart';
import 'package:typed_router/src/operation/operation_redirects.dart';
import 'package:typed_router/src/redirect/redirects.dart';
import 'package:typed_router/src/result/pending_result.dart';
import 'package:typed_router/src/route/typed_route.dart';
import 'package:typed_router/src/state/shell_level.dart';
import 'package:typed_router/src/state/typed_router_state.dart';
import 'package:typed_router/src/transaction/navigation_controller.dart';

/// Carries out the router's stack operations: checks what must hold
/// before, asks the planner for the candidate and hands it to the
/// controller with the navigation's redirects.
///
/// Which redirects each operation runs: [OperationRedirects].
class StackOperations {
  /// Creates operations that plan with [_planner], redirect with
  /// [_redirects] and commit through [_controller].
  StackOperations(this._controller, this._planner, Redirects redirects)
    : _redirects = OperationRedirects(redirects, _planner);

  final NavigationController _controller;
  final NavigationPlanner _planner;
  final OperationRedirects _redirects;

  TypedRouterState get _state => _controller.state;

  /// Whether [pop] can remove an entry: never on the error screen.
  bool get canPop => _state.error == null && _state.entries.length > 1;

  /// See `TypedRouter.go`.
  void go(TypedRoute<Object?> route) => _navigate(
    _planner.goTo(_state, route),
    (redirected) => _planner.goTo(_state, redirected),
  );

  /// The state [go] would build for [route], without redirects and without
  /// committing.
  TypedRouterState plannedGo(TypedRoute<Object?> route) =>
      _planner.goTo(_state, route);

  /// The state [push] would build for [route], without redirects and without
  /// committing.
  TypedRouterState plannedPush(TypedRoute<Object?> route) =>
      _planner.pushedOnto(_state, route);

  /// See `TypedRouter.push`.
  Future<T?> push<T>(TypedRoute<T> route) => _navigateWithNew(
    route,
    (planned, pendingResult) =>
        _planner.pushedOnto(_state, planned, pendingResult: pendingResult),
  );

  /// Shows [branchType] of [tabs]: a navigation with the redirects of the
  /// branch's top route.
  void goBranch(TabsEntry tabs, Type branchType) => _navigate(
    _planner.branchShown(_state, tabs, branchType),
    (redirected) => _planner.goTo(_state, redirected),
  );

  /// Shows [branchType] of [tabs] from its initial route, as [goBranch].
  void resetBranch(TabsEntry tabs, Type branchType) => _navigate(
    _planner.branchReset(_state, tabs, branchType),
    (redirected) => _planner.goTo(_state, redirected),
  );

  /// See `TypedRouter.pop`.
  void pop(Object? result) {
    if (!canPop) throw StateError(_nothingToPop);
    final top = _state.entries.last..checkResult(result);
    top.recordResult(result);
    _controller.navigate(_planner.withoutTop(_state));
  }

  /// See `TypedRouter.popUntil`.
  void popUntil(RoutePredicate predicate) => _controller.navigate(
    _planner.poppedUntil(_state, predicate),
    steps: _redirects.toRemainingRoutes(_state),
  );

  /// See `TypedRouter.replace`.
  Future<T?> replace<T>(TypedRoute<T> route) => _navigateWithNew(
    route,
    (planned, pendingResult) =>
        _planner.withTopUpdated(_state, planned, pendingResult: pendingResult),
  );

  /// See `TypedRouter.pushReplacement`.
  Future<T?> pushReplacement<T>(TypedRoute<T> route) => _navigateWithNew(
    route,
    (planned, pendingResult) =>
        _planner.withTopReplaced(_state, planned, pendingResult: pendingResult),
  );

  /// See `TypedRouter.pushAndRemoveUntil`.
  Future<T?> pushAndRemoveUntil<T>(
    TypedRoute<T> route,
    RoutePredicate predicate,
  ) => _navigateWithNew(
    route,
    (planned, pendingResult) => _planner.pushedAfterPoppingUntil(
      _state,
      planned,
      predicate,
      pendingResult: pendingResult,
    ),
  );

  /// Navigates to the candidate [plan] builds with a new entry for
  /// [route] that [pendingResult] awaits. When no entry it awaits reaches
  /// the committed state (redirected or failed), the push completes with
  /// `null`. A redirect target gets an entry nobody awaits: its result type
  /// is not [T].
  Future<T?> _navigateWithNew<T>(
    TypedRoute<T> route,
    TypedRouterState Function(
      TypedRoute<Object?> route,
      PendingResult<Object?>? pendingResult,
    )
    plan,
  ) {
    final pendingResult = PendingResult<T>();
    _navigate(
      plan(route, pendingResult),
      (redirected) => plan(redirected, null),
    );
    if (!_state.entries.any((entry) => entry.completes(pendingResult))) {
      pendingResult.complete();
    }
    return pendingResult.future;
  }

  void _navigate(
    TypedRouterState candidate,
    TypedRouterState Function(TypedRoute<Object?> redirected) replan,
  ) => _controller.navigate(
    candidate,
    steps: _redirects.toNewRoute(_state, replan),
  );

  String get _nothingToPop => _state.error == null
      ? 'Nothing to pop: the stack has one entry. Check canPop or use go.'
      : 'Nothing to pop: the error screen is shown because the redirects '
            'failed. Use go, or refresh once they pass.';
}
