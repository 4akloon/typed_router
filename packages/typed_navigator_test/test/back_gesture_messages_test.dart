// The gesture sends what the Android embedding sends
// (BackGestureChannel.backEventToJsonMap): the same touchOffset / progress /
// swipeEdge map for start and every update.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator_test/typed_navigator_test.dart';

/// Takes every back gesture and records what reaches the framework.
class _GestureRecorder with WidgetsBindingObserver {
  final List<String> calls = [];

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    calls.add('start ${backEvent.touchOffset} ${backEvent.progress}');
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) =>
      calls.add('update ${backEvent.touchOffset} ${backEvent.progress}');

  @override
  void handleCommitBackGesture() => calls.add('commit');

  @override
  void handleCancelBackGesture() => calls.add('cancel');
}

void main() {
  testWidgets('every step carries the touch position, as on Android', (
    tester,
  ) async {
    final recorder = _GestureRecorder();
    tester.binding.addObserver(recorder);
    addTearDown(() => tester.binding.removeObserver(recorder));

    final gesture = await tester.startPredictiveBack();
    await gesture.moveTo(0);
    await gesture.moveTo(1);
    await gesture.commit();

    expect(recorder.calls, [
      'start Offset(5.0, 300.0) 0.0',
      'update Offset(5.0, 300.0) 0.0',
      'update Offset(405.0, 300.0) 1.0',
      'commit',
    ]);
  });

  testWidgets('a gesture ended by commit takes no more steps; NaN is out of '
      'range', (tester) async {
    final gesture = await tester.startPredictiveBack();

    expect(() => gesture.moveTo(double.nan), throwsArgumentError);
    await gesture.commit();

    expect(() => gesture.moveTo(0.5), throwsStateError);
    expect(gesture.cancel, throwsStateError);
  });
}
