import 'package:meta/meta.dart';
import 'package:typed_router_test/src/back_gesture_channel.dart';

/// An Android predictive back gesture in progress, from the left edge, like
/// flutter_test's `TestGesture`.
///
/// Start one with `TypedRouterTester.startPredictiveBack`, move it with
/// [moveTo] and check the screen mid-gesture, then [commit] or [cancel].
/// Each step sends what the Android embedding sends on
/// `flutter/backgesture`.
///
/// Finish a gesture before starting another. A gesture no page takes (a
/// transition without predictive back, a `PopScope(canPop: false)` on
/// screen) moves nothing; [commit] then falls back to the back button.
///
/// The steps check their arguments and throw synchronously, so
/// `expect(() => gesture.moveTo(2), throwsArgumentError)` works without
/// `await`; once committed or cancelled, any step throws [StateError].
///
/// ```dart
/// final gesture = await tester.startPredictiveBack();
/// await gesture.moveTo(0.5);
/// expect(find.text('Rooms'), findsOneWidget); // the page below shows
/// await gesture.cancel();
/// ```
///
/// Experimental until 1.0: it may change without a major version.
class PredictiveBackGesture {
  /// Wraps a gesture [_channel] has already started.
  @internal
  PredictiveBackGesture(this._channel);

  final BackGestureChannel _channel;
  bool _isOver = false;

  /// Moves the gesture to [progress], from 0 (where it started) to 1 (the
  /// whole way), and pumps a frame. Throws [ArgumentError] for a progress
  /// out of that range, NaN included.
  Future<void> moveTo(double progress) {
    _checkNotOver();
    if (!(progress >= 0 && progress <= 1)) {
      throw ArgumentError.value(progress, 'progress', 'Must be from 0 to 1.');
    }
    return _channel.update(progress);
  }

  /// Lets go: the page under the gesture pops. Settles.
  Future<void> commit() {
    _finish();
    return _channel.commit();
  }

  /// Lets go back where it started: nothing pops. Settles.
  Future<void> cancel() {
    _finish();
    return _channel.cancel();
  }

  void _finish() {
    _checkNotOver();
    _isOver = true;
  }

  void _checkNotOver() {
    if (_isOver) {
      throw StateError('The gesture is over: it was committed or cancelled.');
    }
  }
}
