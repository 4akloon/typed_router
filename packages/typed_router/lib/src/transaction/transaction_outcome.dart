import 'package:typed_router/src/state/typed_router_state.dart';

/// What happened to one navigation.
sealed class TransactionOutcome {
  const TransactionOutcome();
}

/// The navigation changed the screen; [state] is now committed.
class TransactionCommitted extends TransactionOutcome {
  /// Creates the outcome of a commit of [state].
  const TransactionCommitted(this.state);

  /// The committed state.
  final TypedRouterState state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCommitted && other.state == state;

  @override
  int get hashCode => state.hashCode;

  @override
  String toString() => 'TransactionCommitted($state)';
}

/// The navigation ended on the state already committed; nothing changed
/// and nobody was notified.
class TransactionUnchanged extends TransactionOutcome {
  /// Creates the outcome of a navigation that changed nothing.
  const TransactionUnchanged();

  @override
  bool operator ==(Object other) => other is TransactionUnchanged;

  @override
  int get hashCode => (TransactionUnchanged).hashCode;

  @override
  String toString() => 'TransactionUnchanged()';
}

/// A step failed; the state is unchanged and the [error] was reported
/// through `FlutterError.reportError`.
class TransactionFailed extends TransactionOutcome {
  /// Creates the outcome of a navigation that failed with [error].
  const TransactionFailed(this.error, this.stackTrace);

  /// What the step threw.
  final Object error;

  /// Where the step threw it.
  final StackTrace stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionFailed &&
          other.error == error &&
          other.stackTrace == stackTrace;

  @override
  int get hashCode => Object.hash(error, stackTrace);

  @override
  String toString() => 'TransactionFailed($error)';
}
