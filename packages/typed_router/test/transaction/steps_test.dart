// Steps, failures and forbidden calls.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/src/transaction/navigation_controller.dart';
import 'package:typed_router/src/transaction/transaction_outcome.dart';
import 'package:typed_router/typed_router.dart';

import '../support/route_fixtures.dart';
import '../support/state_fixtures.dart';
import '../support/transaction_fixtures.dart';

const rooms = RoomsRoute();
const room7 = RoomRoute(RoomId(7));

void main() {
  late ManualFramePhase framePhase;
  late ReportedErrors reportedErrors;

  setUp(() {
    framePhase = ManualFramePhase();
    reportedErrors = ReportedErrors()..start();
  });

  tearDown(() => reportedErrors.stop());

  NavigationController controllerAtRooms() => NavigationController(
    initialState: stateOf([rooms]),
    framePhase: framePhase,
  );

  test('a step can replace the candidate and steps run in order', () {
    final firstReplacement = stateOf([room7]);
    final secondReplacement = stateOf([const SignInRouteForSteps()]);
    final firstStep = ReplacingStep(firstReplacement);
    final secondStep = ReplacingStep(secondReplacement);
    final controller = controllerAtRooms();

    controller.navigate(
      stateOf([rooms, room7]),
      steps: [firstStep, secondStep],
    );

    expect(secondStep.receivedCandidates, [firstReplacement]);
    expect(controller.state, secondReplacement);
  });

  test('a step that throws leaves the state unchanged and reports the '
      'error', () {
    final controller = controllerAtRooms();
    final stateBefore = controller.state;
    var notifications = 0;
    controller.addListener(() => notifications++);

    final outcome = controller.navigate(
      stateOf([rooms, room7]),
      steps: [ThrowingStep()],
    );

    expect(controller.state, stateBefore);
    expect(notifications, 0);
    expect(outcome, isA<TransactionFailed>());
    expect(reportedErrors.details, hasLength(1));
    expect(reportedErrors.details.single.library, 'typed_router');
    expect(reportedErrors.details.single.exception, isA<StateError>());
  });

  test('navigating from inside a step fails in debug', () {
    final step = NavigatingStep();
    final controller = controllerAtRooms();
    step.controller = controller;

    final outcome = controller.navigate(stateOf([rooms, room7]), steps: [step]);

    expect(outcome, isA<TransactionFailed>());
    expect(reportedErrors.details.single.exception, isA<AssertionError>());
  });

  test('navigating while widgets build fails in debug', () {
    final controller = controllerAtRooms();
    framePhase.isBuilding = true;

    expect(
      () => controller.navigate(stateOf([rooms, room7])),
      throwsAssertionError,
    );
  });
}

/// A route only these tests navigate to.
class SignInRouteForSteps extends TypedRoute<void> {
  const SignInRouteForSteps();

  @override
  List<Object?> get fields => const [];
}
