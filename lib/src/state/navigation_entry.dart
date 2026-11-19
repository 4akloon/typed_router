import 'package:flutter/foundation.dart';
import 'package:typed_navigator/src/result/pending_result.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/shell_entry.dart';

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
  /// Creates an entry for [route] inside [shells] (outer first);
  /// `pendingResult` when a push awaits it.
  NavigationEntry(
    this.route, {
    List<ShellEntry> shells = const [],
    this._pendingResult,
  }) : shells = List.unmodifiable(shells);

  /// The route shown by this page.
  final TypedRoute<Object?> route;

  /// The shell instances this page stands in, from the outer one in; empty for
  /// a page of the root navigator.
  final List<ShellEntry> shells;

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

  /// Whether leaving this entry completes [pendingResult]: the push that
  /// created it awaits this entry.
  bool completes(PendingResult<Object?> pendingResult) =>
      identical(_pendingResult, pendingResult);

  /// The entry left the state: completes the push awaiting it.
  void leave() => _pendingResult?.complete();

  @override
  String toString() => 'NavigationEntry($route)';
}
