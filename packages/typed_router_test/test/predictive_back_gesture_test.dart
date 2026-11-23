// A predictive back gesture driven step by step.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router_test/typed_router_test.dart';

import 'support/rooms_app.dart';

final _android = TargetPlatformVariant.only(TargetPlatform.android);

Future<PushedRoom> _roomOverRooms(WidgetTester tester) =>
    pumpRoomOverRooms(tester, theme: predictiveBackTheme);

void main() {
  testWidgets('mid-gesture the top page is still on the stack and the page '
      'below shows', (tester) async {
    final room = await _roomOverRooms(tester);
    expect(find.text('Rooms'), findsNothing);

    final gesture = await tester.startPredictiveBack();
    await gesture.moveTo(0.5);

    expect(room.isCompleted, isFalse);
    expect(find.text('Rooms'), findsOneWidget);
    expect(find.text('Room 7'), findsOneWidget);
    await gesture.cancel();
  }, variant: _android);

  testWidgets('commit pops the top page', (tester) async {
    final room = await _roomOverRooms(tester);

    final gesture = await tester.startPredictiveBack();
    await gesture.moveTo(0.2);
    final nearStart = tester.getTopLeft(find.text('Room 7'));
    await gesture.moveTo(0.8);
    // The gesture reaches the route: the page moves, the page below shows.
    expect(tester.getTopLeft(find.text('Room 7')), isNot(nearStart));
    expect(find.text('Rooms'), findsOneWidget);
    await gesture.commit();

    expectRoomsOnly();
    expect(room.completions, [null]);
  }, variant: _android);

  testWidgets('cancel pops nothing', (tester) async {
    final room = await _roomOverRooms(tester);

    final gesture = await tester.startPredictiveBack();
    await gesture.moveTo(0.6);
    await gesture.cancel();

    expect(room.isCompleted, isFalse);
    expect(find.text('Room 7'), findsOneWidget);
    expect(find.text('Rooms'), findsNothing);
  }, variant: _android);

  testWidgets('a progress out of range or a step after the end fails', (
    tester,
  ) async {
    await _roomOverRooms(tester);
    final gesture = await tester.startPredictiveBack();

    expect(() => gesture.moveTo(1.5), throwsArgumentError);
    expect(() => gesture.moveTo(-0.1), throwsArgumentError);
    await gesture.cancel();

    expect(() => gesture.moveTo(0.5), throwsStateError);
    expect(gesture.commit, throwsStateError);
    expect(gesture.cancel, throwsStateError);
  }, variant: _android);
}
