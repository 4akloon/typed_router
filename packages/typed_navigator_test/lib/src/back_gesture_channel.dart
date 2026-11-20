import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sends a predictive back gesture from the left edge to the app as the Android
/// embedding does (`BackGestureChannel.backEventToJsonMap`): the same
/// `touchOffset`, `progress` and `swipeEdge` map for the start and every
/// update, nothing for commit and cancel.
///
/// Internal: `PredictiveBackGesture` drives it.
final class BackGestureChannel {
  /// Creates the channel of [_tester]'s binding.
  BackGestureChannel(this._tester);

  final WidgetTester _tester;

  /// Where the finger starts: near the left edge, mid-height.
  static const double _startX = 5;
  static const double _touchY = 300;

  /// How far the finger travels at progress 1.
  static const double _travel = 400;

  /// Starts the gesture and pumps a frame.
  Future<void> start() async {
    await _send('startBackGesture', _event(0));
    await _tester.pump();
  }

  /// Moves the gesture to [progress] and pumps a frame.
  Future<void> update(double progress) async {
    await _send('updateBackGestureProgress', _event(progress));
    await _tester.pump();
  }

  /// Ends the gesture with the page popped, then settles.
  Future<void> commit() async {
    await _send('commitBackGesture');
    await _tester.pumpAndSettle();
  }

  /// Ends the gesture where it started, then settles.
  Future<void> cancel() async {
    await _send('cancelBackGesture');
    await _tester.pumpAndSettle();
  }

  Map<String, Object?> _event(double progress) => {
    'touchOffset': <double>[_startX + _travel * progress, _touchY],
    'progress': progress,
    'swipeEdge': 0,
  };

  Future<void> _send(String method, [Map<String, Object?>? arguments]) =>
      _tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/backgesture',
        const StandardMethodCodec().encodeMethodCall(
          MethodCall(method, arguments),
        ),
        (_) {},
      );
}
