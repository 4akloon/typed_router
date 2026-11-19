import 'package:flutter/foundation.dart';
import 'package:typed_navigator/src/result/pending_result.dart';
import 'package:typed_navigator/src/route/typed_route.dart';

/// One page on a stack: a route together with the identity of its page,
/// and the push waiting for its result, if any.
///
/// Entries are compared by identity, not by value. Two entries holding
/// equal routes are different pages: when the router builds a new entry
/// for an equal route, the page is built again. That is why this class
/// does not override `==`.
///
/// Internal: not exported.
final class NavigationEntry {
  /// Creates an entry for [route]; `pendingResult` when a push awaits it.
  NavigationEntry(this.route, {this._pendingResult});

  /// The route shown by this page.
  final TypedRoute<Object?> route;

  final PendingResult<Object?>? _pendingResult;

  /// Throws [ArgumentError] when the push awaiting this entry cannot take
  /// [result]. An entry nobody awaits takes anything and drops it.
  void checkResult(Object? result) {
    if (_pendingResult case final pending? when !pending.accepts(result)) {
      throw pending.mismatch(route, result);
    }
  }

  /// Keeps [result] for the push, which completes when the entry leaves.
  void recordResult(Object? result) => _pendingResult?.record(result);

  /// Keeps a [result] the navigator popped this page with
  /// (`Navigator.pop(context, result)`). One of another type is reported
  /// through [FlutterError.reportError] and dropped: the navigator is in
  /// the middle of a pop and must not be interrupted.
  void offerNativeResult(Object? result) {
    if (_pendingResult case final pending? when !pending.accepts(result)) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: pending.mismatch(route, result),
          library: 'typed_navigator',
          context: ErrorDescription('while Navigator.pop closed $route'),
        ),
      );
      return;
    }
    recordResult(result);
  }

  /// The entry left the state: completes the push awaiting it.
  void leave() => _pendingResult?.complete();

  @override
  String toString() => 'NavigationEntry($route)';
}
