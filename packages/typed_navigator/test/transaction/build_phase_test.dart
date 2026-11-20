// The router re-checks its stack while its widgets build; listeners hear about
// it after the frame, once.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/src/transaction/navigation_controller.dart';

import '../support/route_fixtures.dart';
import '../support/state_fixtures.dart';
import '../support/transaction_fixtures.dart';

const rooms = RoomsRoute();
const room7 = RoomRoute(RoomId(7));

void main() {
  late ManualFramePhase framePhase;
  late NavigationController controller;
  var notifications = 0;

  setUp(() {
    framePhase = ManualFramePhase()..isBuilding = true;
    controller = NavigationController(
      initialState: stateOf([rooms]),
      framePhase: framePhase,
    );
    notifications = 0;
    controller.addListener(() => notifications++);
  });

  test('changes while building commit at once and notify after the frame, '
      'once', () {
    final first = stateOf([rooms, room7]);
    final second = stateOf([room7]);

    controller.changeWhileBuilding(() {
      controller
        ..navigate(first)
        ..applyExternalChange(second);
    });

    expect(controller.state, second);
    expect(notifications, 0);
    framePhase.endFrame();
    expect(notifications, 1);
  });

  test('a controller disposed before the frame ends notifies nobody', () {
    controller.changeWhileBuilding(
      () => controller.navigate(stateOf([rooms, room7])),
    );
    controller.dispose();

    framePhase.endFrame();

    expect(notifications, 0);
  });
}
