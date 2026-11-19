// A predictive back gesture driven step by step.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/testing.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/back_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/shell_fixtures.dart';

final android = TargetPlatformVariant.only(TargetPlatform.android);

Future<(TypedRouter, ResultProbe<Object?>)> _roomOverRooms(
  WidgetTester tester,
) async {
  final router = await pumpMaterialRooms(tester, theme: predictiveBackTheme);
  final room = await pushAndSettle(tester, router, room7);
  return (router, room);
}

void main() {
  testWidgets('mid-gesture the top page is still on the stack and the page '
      'below shows', (tester) async {
    final (router, _) = await _roomOverRooms(tester);
    expect(find.text('Rooms'), findsNothing);

    final gesture = await tester.startPredictiveBack();
    await gesture.moveTo(0.5);

    expect(router.state.routes, const [rooms, room7]);
    expect(find.text('Rooms'), findsOneWidget);
    expect(find.text('Room 7'), findsOneWidget);
    await gesture.cancel();
  }, variant: android);

  testWidgets('commit pops the top page', (tester) async {
    final (router, room) = await _roomOverRooms(tester);

    final gesture = await tester.startPredictiveBack();
    await gesture.moveTo(0.2);
    final nearStart = tester.getTopLeft(find.text('Room 7'));
    await gesture.moveTo(0.8);
    // The gesture reaches the route: the page moves, the page below shows.
    expect(tester.getTopLeft(find.text('Room 7')), isNot(nearStart));
    expect(find.text('Rooms'), findsOneWidget);
    await gesture.commit();

    expect(router.state.routes, const [rooms]);
    expect(room.completions, [null]);
  }, variant: android);

  testWidgets('cancel pops nothing', (tester) async {
    final (router, room) = await _roomOverRooms(tester);

    final gesture = await tester.startPredictiveBack();
    await gesture.moveTo(0.6);
    await gesture.cancel();

    expect(router.state.routes, const [rooms, room7]);
    expect(room.isCompleted, isFalse);
    expect(find.text('Room 7'), findsOneWidget);
    expect(find.text('Rooms'), findsNothing);
  }, variant: android);

  testWidgets('mid-gesture over a shell only the root page moves', (
    tester,
  ) async {
    final router = TypedRouter(
      routes: shellRoutes(FrameLog()),
      initialRoute: user1,
      pageFactory: const MaterialPageFactory(),
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: predictiveBackTheme),
    );
    await settleAfter(tester, () => router.push(account).ignore());
    expect(find.text('User u1'), findsNothing);

    final gesture = await tester.startPredictiveBack();
    await gesture.moveTo(0.5);

    expect(router.state.top, account);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('User u1'), findsOneWidget);
    expect(find.text('Users'), findsNothing);
    await gesture.commit();
    expect(router.state.toString(), '[UsersRoute() > UserRoute(u1)]');
  }, variant: android);

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
  }, variant: android);
}
