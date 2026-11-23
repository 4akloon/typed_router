import 'dart:async';

import 'package:typed_router/src/route/typed_route.dart';

// Messages name the route and result types; type names are readable in debug
// builds, where these errors are met.
// ignore_for_file: avoid_type_to_string

/// The future of one `push`, waiting for the result of type [T] its entry
/// leaves with.
///
/// Created where [T] is known (`push<T>`), so it can check results that
/// arrive untyped. Completes exactly once: with the recorded result, or
/// `null` when none was recorded.
class PendingResult<T> {
  final Completer<T?> _completer = Completer<T?>();
  T? _result;

  /// What the `push` returns.
  Future<T?> get future => _completer.future;

  /// Whether [result] is a value this push can complete with.
  bool accepts(Object? result) => result == null || result is T;

  /// The error for a [result] that [route]'s push cannot complete with.
  ArgumentError mismatch(TypedRoute<Object?> route, Object? result) =>
      ArgumentError('$route awaits a $T?, got ${result.runtimeType}.');

  /// Keeps [result] for [complete]; ignores a value of another type.
  void record(Object? result) {
    if (result case final T typed) _result = typed;
  }

  /// Completes the future with the recorded result, or `null`. Later calls
  /// do nothing.
  void complete() {
    if (_completer.isCompleted) return;
    _completer.complete(_result);
  }
}
