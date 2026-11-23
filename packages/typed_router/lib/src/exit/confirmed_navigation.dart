import 'dart:async';

import 'package:typed_router/src/exit/exit_questions.dart';
import 'package:typed_router/src/redirect/stack_recheck.dart';
import 'package:typed_router/src/state/typed_router_state.dart';
import 'package:typed_router/src/transaction/navigation_controller.dart';
import 'package:typed_router/src/transaction/navigation_step.dart';
import 'package:typed_router/src/transaction/transaction_outcome.dart';

/// Commits an operation's navigation once the pages it removes from the screen
/// agree to leave (`onExit`): at once when every answer is a `bool`, else when
/// the answers come.
///
/// One navigation waits at a time. Any other change to the state drops it: a
/// newer navigation that commits or waits in turn, a re-check of the stack, a
/// page popped outside the router, `dispose`. A newer navigation that changes
/// nothing (or is refused at once) leaves it waiting. A dropped one never
/// commits, whatever its hooks answer later; nor does one whose state changed
/// while its hooks were asked (a re-check a hook started).
class ConfirmedNavigation {
  /// Creates the navigation that commits through [_controller] after
  /// [_questions] agree; [_recheck] checks the stack after a navigation that
  /// waited commits.
  ConfirmedNavigation(this._controller, this._questions, this._recheck) {
    _controller.addListener(_drop);
  }

  final NavigationController _controller;
  final ExitQuestions _questions;
  final StackRecheck _recheck;
  _WaitingNavigation? _waiting;

  /// Runs [candidate] through [steps], asks the pages that would leave, and
  /// commits; [beforeCommit] runs right before the commit, [afterwards] once
  /// the navigation committed, was refused, failed or was dropped.
  ///
  /// In debug, navigating from inside an `onExit` call fails with an
  /// [AssertionError].
  void navigate(
    TypedRouterState candidate, {
    List<NavigationStep> steps = const [],
    void Function()? beforeCommit,
    void Function()? afterwards,
  }) {
    assert(
      !_questions.isAsking,
      'onExit navigated. Return false and navigate after it, or navigate '
      'after an await.',
    );
    final current = _controller.state;
    final outcome = _controller.planned(candidate, steps: steps);
    if (outcome is! TransactionPlanned) return afterwards?.call();
    final waiting = _WaitingNavigation(
      current,
      outcome.state,
      beforeCommit,
      afterwards,
    );
    switch (_questions.mayLeave(current, outcome.state)) {
      case final bool mayLeave:
        // A commit notifies, and the listener drops an older waiting one.
        if (mayLeave) _commit(waiting);
        waiting.afterwards?.call();
      case final Future<bool> later:
        _drop();
        _waiting = waiting;
        unawaited(
          later.then((mayLeave) {
            if (!identical(_waiting, waiting)) return;
            _waiting = null;
            if (mayLeave) _commitAfterWaiting(waiting);
            waiting.afterwards?.call();
          }),
        );
    }
  }

  /// Drops the waiting navigation; called before the router is disposed.
  void dispose() => _drop();

  // A hook may change the state while it is asked, before this navigation
  // waits: a re-check it starts commits through the controller and wins.
  void _commit(_WaitingNavigation waiting) {
    if (!identical(_controller.state, waiting.from)) return;
    waiting.beforeCommit?.call();
    _controller.commit(waiting.target);
  }

  // The redirects ran when the navigation was asked for; the session may have
  // changed while it waited without changing the stack then shown, so the
  // guard checks the stack again, as refresh() does.
  void _commitAfterWaiting(_WaitingNavigation waiting) {
    _commit(waiting);
    _recheck.recheck();
  }

  void _drop() {
    final dropped = _waiting;
    _waiting = null;
    dropped?.afterwards?.call();
  }
}

/// A navigation waiting for its `onExit` answers.
class _WaitingNavigation {
  _WaitingNavigation(
    this.from,
    this.target,
    this.beforeCommit,
    this.afterwards,
  );

  final TypedRouterState from;
  final TypedRouterState target;
  final void Function()? beforeCommit;
  final void Function()? afterwards;
}
