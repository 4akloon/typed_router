import 'package:flutter/foundation.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/transaction/entry_lifecycle.dart';
import 'package:typed_navigator/src/transaction/frame_phase.dart';
import 'package:typed_navigator/src/transaction/navigation_step.dart';
import 'package:typed_navigator/src/transaction/navigation_transaction.dart';
import 'package:typed_navigator/src/transaction/transaction_outcome.dart';

/// The single owner of the committed [NavigationState].
///
/// Accepts navigation candidates and changes made outside the router,
/// commits them synchronously and notifies listeners only when the state
/// really changed. Delegates the steps to a [NavigationTransaction].
final class NavigationController extends ChangeNotifier {
  /// Creates a controller that starts at [initialState] without a
  /// notification.
  NavigationController({
    required NavigationState initialState,
    List<NavigationStep> steps = const [],
    this._framePhase = const FramePhase.scheduler(),
    this._entryLifecycle = const EntryLifecycle.ignoring(),
  }) : _state = initialState,
       _transaction = NavigationTransaction(steps);

  final NavigationTransaction _transaction;
  final FramePhase _framePhase;
  final EntryLifecycle _entryLifecycle;
  NavigationState _state;
  bool _isDisposed = false;

  /// The committed state.
  NavigationState get state => _state;

  /// Runs [candidate] through the steps and commits the result before
  /// returning.
  ///
  /// A step that throws is reported through [FlutterError.reportError];
  /// the state stays as it was. In debug, navigating from inside a step or
  /// while widgets build fails with an [AssertionError].
  TransactionOutcome navigate(NavigationState candidate) {
    _checkUsable();
    assert(
      !_transaction.isRunning,
      'A navigation step navigated. Return the target state from the step '
      'instead of calling the router.',
    );
    assert(
      !_framePhase.isBuilding,
      'Navigation was requested while widgets build. Navigate from a '
      'callback, or schedule it with addPostFrameCallback.',
    );
    final NavigationState next;
    try {
      next = _transaction.run(_state, candidate);
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

  /// Reports every entry as left, then releases the listeners. Any later
  /// navigation throws [StateError].
  @override
  void dispose() {
    _isDisposed = true;
    _entryLifecycle.entriesLeft(_state.entries);
    super.dispose();
  }

  TransactionOutcome _commit(NavigationState next) {
    if (next == _state) return const TransactionUnchanged();
    final entriesThatLeft = _state.entriesMissingFrom(next);
    _state = next;
    if (entriesThatLeft.isNotEmpty) {
      _entryLifecycle.entriesLeft(entriesThatLeft);
    }
    notifyListeners();
    return TransactionCommitted(next);
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
