// Listeners, external changes, dispose.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/src/transaction/navigation_controller.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/route_fixtures.dart';
import '../support/state_fixtures.dart';
import '../support/transaction_fixtures.dart';

const rooms = RoomsRoute();
const room7 = RoomRoute(RoomId(7));
const room8 = RoomRoute(RoomId(8));

void main() {
  late RecordingEntryLifecycle entryLifecycle;
  late ReplacingStep step;

  setUp(() {
    entryLifecycle = RecordingEntryLifecycle();
    step = ReplacingStep(stateOf([room8]));
  });

  NavigationController controllerAt(
    NavigationState initialState, {
    bool withStep = false,
  }) => NavigationController(
    initialState: initialState,
    steps: withStep ? [step] : const [],
    framePhase: ManualFramePhase(),
    entryLifecycle: entryLifecycle,
  );

  test('a listener may navigate after a commit', () {
    final controller = controllerAt(stateOf([rooms]));
    final listenerTarget = stateOf([rooms, room8]);
    var hasNavigated = false;
    controller.addListener(() {
      if (hasNavigated) return;
      hasNavigated = true;
      controller.navigate(listenerTarget);
    });

    controller.navigate(stateOf([rooms, room7]));

    expect(controller.state, listenerTarget);
  });

  test('an external change commits as it is, without steps', () {
    final controller = controllerAt(stateOf([rooms, room7]), withStep: true);
    final afterPop = stateOf([rooms]);
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.applyExternalChange(afterPop);

    expect(controller.state, afterPop);
    expect(step.receivedCandidates, isEmpty);
    expect(notifications, 1);
  });

  test('after dispose a navigation throws', () {
    final controller = controllerAt(stateOf([rooms]))..dispose();

    expect(
      () => controller.navigate(stateOf([rooms, room7])),
      throwsStateError,
    );
    expect(
      () => controller.applyExternalChange(stateOf([room7])),
      throwsStateError,
    );
  });

  test('dispose reports every entry as left', () {
    final initialState = stateOf([rooms, room7]);
    controllerAt(initialState).dispose();

    expect(entryLifecycle.reports.single.map((entry) => entry.route), [
      rooms,
      room7,
    ]);
  });
}
