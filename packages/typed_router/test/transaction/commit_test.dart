// Committing and notifying.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/src/state/navigation_entry.dart';
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
  late RecordingEntryLifecycle entryLifecycle;

  setUp(() {
    framePhase = ManualFramePhase();
    entryLifecycle = RecordingEntryLifecycle();
  });

  NavigationController controllerAt(TypedRouterState initialState) =>
      NavigationController(
        initialState: initialState,
        framePhase: framePhase,
        entryLifecycle: entryLifecycle,
      );

  test('a navigation without steps commits before the call returns', () {
    final controller = controllerAt(stateOf([rooms]));
    final candidate = stateOf([rooms, room7]);

    final outcome = controller.navigate(candidate);

    expect(controller.state, candidate);
    expect(outcome, TransactionCommitted(candidate));
  });

  test('listeners get one notification per commit that changes the state', () {
    final controller = controllerAt(stateOf([rooms]));
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.navigate(stateOf([rooms, room7]));
    controller.navigate(stateOf([room7]));

    expect(notifications, 2);
  });

  test('a candidate equal to the current state commits nothing and '
      'notifies nobody', () {
    final initialState = stateOf([rooms]);
    final controller = controllerAt(initialState);
    var notifications = 0;
    controller.addListener(() => notifications++);

    final outcome = controller.navigate(initialState);

    expect(outcome, const TransactionUnchanged());
    expect(notifications, 0);
    expect(entryLifecycle.reports, isEmpty);
  });

  test('a commit reports the entries that left, by identity', () {
    final roomsEntry = NavigationEntry(rooms);
    final roomEntry = NavigationEntry(room7);
    final controller = controllerAt(
      TypedRouterState.fromEntries([roomsEntry, roomEntry]),
    );

    controller.navigate(
      TypedRouterState.fromEntries([roomsEntry, NavigationEntry(room7)]),
    );

    expect(entryLifecycle.reports, [
      [roomEntry],
    ]);
  });

  test('the initial state is committed without a notification', () {
    final initialState = stateOf([rooms]);
    var notifications = 0;

    final controller = controllerAt(initialState)
      ..addListener(() => notifications++);

    expect(controller.state, initialState);
    expect(notifications, 0);
    expect(entryLifecycle.reports, isEmpty);
  });
}
