import 'package:flutter/foundation.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/transaction/entry_lifecycle.dart';
import 'package:typed_navigator/src/transaction/frame_phase.dart';
import 'package:typed_navigator/src/transaction/left_entries.dart';
import 'package:typed_navigator/src/transaction/navigation_step.dart';
import 'package:typed_navigator/src/transaction/navigation_transaction.dart';
import 'package:typed_navigator/src/transaction/transaction_outcome.dart';

/// The single owner of the committed [NavigationState].
///
/// Accepts navigation candidates and changes made outside the router,
/// commits them synchronously and notifies listeners only when the state
/// really changed. Delegates the steps to a [NavigationTransaction].
final class NavigationController extends ChangeNotifier {
  /// Creates a controller at [initialState], without a notification.
  NavigationController({
    required NavigationState initialState,
    this._framePhase = const FramePhase.scheduler(),
    this._entryLifecycle = const EntryLifecycle.ignoring(),
  }) : _state = initialState;

  final NavigationTransaction _transaction = NavigationTransaction();
  final LeftEntries _leftEntries = const LeftEntries();
  final FramePhase _framePhase;
  final EntryLifecycle _entryLifecycle;
  NavigationState _state;
  bool _isDisposed = false;
  bool _isChangingWhileBuilding = false;
  bool _hasNotificationAfterFrame = false;

  /// The committed state.
  NavigationState get state => _state;

  /// Runs [candidate] through the [steps] of this navigation and commits
  /// the result before returning.
  ///
  /// A step that throws is reported through [FlutterError.reportError];
  /// the state stays as it was. In debug, navigating from inside a step or
  /// while widgets build (outside [changeWhileBuilding]) fails with an
  /// [AssertionError].
  TransactionOutcome navigate(
    NavigationState candidate, {
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
    final NavigationState next;
    try {
      next = _transaction.run(_state, candidate, steps);
    } catch (error, stackTrace) {
      // The one place that catches whatever a user step throws, reports it and
      // leaves the state unchanged.
      _reportStepFailure(error, stackTrace, candidate);
      return TransactionFailed(error, stackTrace);
    }
    return _commit(next);
  }

  /// Commits [next] as it is, without steps: a change the router did not
  /// start, such as a page popped by the platform.
  TransactionOutcome applyExternalChange(NavigationState next) {
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
    _entryLifecycle.entriesLeft(_state.allEntries);
    super.dispose();
  }

  TransactionOutcome _commit(NavigationState next) {
    if (next == _state) return const TransactionUnchanged();
    final entriesThatLeft = _leftEntries.between(_state, next);
    _state = next;
    if (entriesThatLeft.isNotEmpty) {
      _entryLifecycle.entriesLeft(entriesThatLeft);
    }
    _notify();
    return TransactionCommitted(next);
  }

  void _notify() {
    if (!_isChangingWhileBuilding) return notifyListeners();
    if (_hasNotificationAfterFrame) return;
    _hasNotificationAfterFrame = true;
    _framePhase.afterFrame(() {
      _hasNotificationAfterFrame = false;
      if (!_isDisposed) notifyListeners();
    });
  }

  void _checkUsable() {
    if (_isDisposed) {
      throw StateError('The navigation controller was used after dispose.');
    }
  }

  void _reportStepFailure(
    Object error,
    StackTrace stackTrace,
    NavigationState candidate,
  ) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'typed_navigator',
        context: ErrorDescription('while navigating to ${candidate.top}'),
      ),
    );
  }
}
