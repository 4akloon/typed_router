// Predictive back in the deepest column shows what takes its place: the
// placeholder of the column to its left.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/testing.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/back_fixtures.dart';
import '../support/split_fixtures.dart';

final android = TargetPlatformVariant.only(TargetPlatform.android);

Future<void> _pump(WidgetTester tester, TypedRoute<Object?> top) async {
  setWindowWidth(tester, 1200);
  final router = TypedRouter(
    routes: [roomsSplit(ScreenLog(), columns: 3)],
    initialRoute: top,
    pageFactory: const MaterialPageFactory(),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(routerConfig: router, theme: predictiveBackTheme),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('predictive back in the deepest column shows the placeholder '
      'of the column to its left', (tester) async {
    await _pump(tester, room1);
    expect(find.text('Pick a room'), findsNothing);

    final gesture = await tester.startPredictiveBack();
    await gesture.moveTo(0.5);

    expect(find.text('Pick a room'), findsOneWidget);
    await gesture.cancel();
  }, variant: android);

  testWidgets('without a placeholder to its left, predictive back in the '
      'deepest column shows an empty page', (tester) async {
    await _pump(tester, playerAnn);

    final gesture = await tester.startPredictiveBack();
    await gesture.moveTo(0.5);

    expect(find.text('Pick a room'), findsNothing);
    await gesture.cancel();
  }, variant: android);
}
