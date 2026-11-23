import 'package:flutter/foundation.dart';
import 'package:typed_router/src/state/typed_router_state.dart';
import 'package:typed_router/src/transaction/entry_lifecycle.dart';
import 'package:typed_router/src/transaction/frame_phase.dart';
import 'package:typed_router/src/transaction/left_entries.dart';
import 'package:typed_router/src/transaction/navigation_step.dart';
import 'package:typed_router/src/transaction/navigation_transaction.dart';
import 'package:typed_router/src/transaction/notification_after_frame.dart';
import 'package:typed_router/src/transaction/step_failure_report.dart';
import 'package:typed_router/src/transaction/transaction_outcome.dart';

/// The single owner of the committed [TypedRouterState].
///
/// Accepts navigation candidates and changes made outside the router,
/// commits them synchronously and notifies listeners only when the state
/// really changed. Delegates the steps to a [NavigationTransaction].
class NavigationController extends ChangeNotifier {
  /// Creates a controller at [initialState], without a notification.
  NavigationController({
    required TypedRouterState initialState,
    this._framePhase = const FramePhase.scheduler(),
    this._entryLifecycle = const EntryLifecycle.ignoring(),
  }) : _state = initialState,
       _afterFrame = NotificationAfterFrame(_framePhase);

  final NavigationTransaction _transaction = NavigationTransaction();
  final LeftEntries _leftEntries = const LeftEntries();
  final StepFailureReport _stepFailureReport = const StepFailureReport();
  final FramePhase _framePhase;
  final NotificationAfterFrame _afterFrame;
  final EntryLifecycle _entryLifecycle;
  TypedRouterState _state;
  bool _isDisposed = false;
  bool _isChangingWhileBuilding = false;

  /// The committed state.
  TypedRouterState get state => _state;

  /// Whether [dispose] was called.
  bool get isDisposed => _isDisposed;

  /// Runs [candidate] through the [steps] of this navigation and commits
  /// the result before returning.
  ///
  /// A step that throws is reported through [FlutterError.reportError];
  /// the state stays as it was. In debug, navigating from inside a step or
  /// while widgets build (outside [changeWhileBuilding]) fails with an
  /// [AssertionError].
  TransactionOutcome navigate(
    TypedRouterState candidate, {
    List<NavigationStep> steps = const [],
  }) => switch (planned(candidate, steps: steps)) {
    TransactionPlanned(:final state) => _commit(state),
    final outcome => outcome,
  };

  /// Runs [candidate] through [steps] without committing: the state they
  /// settle on, or [TransactionFailed]. Checks as [navigate] does.
  TransactionOutcome planned(
    TypedRouterState candidate, {
    List<NavigationStep> steps = const [],
  }) {
    _checkUsable();
    assert(
      !_transaction.isRunning,
      'A navigation step navigated. Return the target state from the step '
      'instead of calling the router.',
    );
    assert(
      _isChangingWhileBuilding || !_framePhase.isBuilding,
      'Navigation was requested while widgets build. Navigate from a '
      'callback, or schedule it with addPostFrameCallback.',
    );
    try {
      return TransactionPlanned(_transaction.run(_state, candidate, steps));
    } catch (error, stackTrace) {
      // The one place that catches whatever a user step throws, reports it and
      // leaves the state unchanged.
      _stepFailureReport.report(error, stackTrace, candidate);
      return TransactionFailed(error, stackTrace);
    }
  }

  /// Commits [next], which [planned] settled on and whose leaving pages
  /// agreed to go.
  TransactionOutcome commit(TypedRouterState next) {
    _checkUsable();
    return _commit(next);
  }

  /// Commits [next] as it is, without steps: a change the router did not
  /// start, such as a page popped by the platform.
  TransactionOutcome applyExternalChange(TypedRouterState next) {
    _checkUsable();
    return _commit(next);
  }

  /// Runs [changes], which navigate while widgets build: the router checking
  /// its stack as it is shown. Listeners (the `Router` above among them, which
  /// cannot be marked dirty now) hear once, after the frame; whoever builds
  /// below reads [state] in this frame.
  void changeWhileBuilding(void Function() changes) {
    _isChangingWhileBuilding = true;
    try {
      changes();
    } finally {
      _isChangingWhileBuilding = false;
    }
  }

  /// Adds [listener]; throws [StateError] after [dispose].
  @override
  void addListener(VoidCallback listener) {
    _checkUsable();
    super.addListener(listener);
  }

  /// Reports every entry as left (on screen and in branches not on
  /// screen), then releases the listeners. Any later navigation, added
  /// listener or second dispose throws [StateError]; removing one is fine.
  @override
  void dispose() {
    _checkUsable();
    _isDisposed = true;
    _entryLifecycle.stackDisposed(_state.allEntries);
    super.dispose();
  }

  TransactionOutcome _commit(TypedRouterState next) {
    if (next == _state) return const TransactionUnchanged();
    final entriesThatLeft = _leftEntries.between(_state, next);
    _state = next;
    if (entriesThatLeft.isNotEmpty) {
      _entryLifecycle.entriesLeft(entriesThatLeft, next);
    }
    _notify();
    return TransactionCommitted(next);
  }

  void _notify() {
    if (!_isChangingWhileBuilding) return notifyListeners();
    _afterFrame.schedule(() {
      if (!_isDisposed) notifyListeners();
    });
  }

  void _checkUsable() {
    if (_isDisposed) {
      throw StateError('The navigation controller was used after dispose.');
    }
  }
}
