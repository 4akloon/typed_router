// A back gesture in columns goes only to the deepest column
// (flutter/flutter#152323), not to every column at once.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/testing.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/back_fixtures.dart';
import '../support/split_fixtures.dart';

final android = TargetPlatformVariant.only(TargetPlatform.android);
final iOS = TargetPlatformVariant.only(TargetPlatform.iOS);

Future<TypedRouter> _pumpMaterialSplit(
  WidgetTester tester, {
  double width = 1200,
}) async {
  setWindowWidth(tester, width);
  final router = TypedRouter(
    routes: [roomsSplit(ScreenLog(), columns: 3)],
    initialRoute: playerAnn,
    pageFactory: const MaterialPageFactory(),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(routerConfig: router, theme: predictiveBackTheme),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('predictive back in columns closes only the deepest one', (
    tester,
  ) async {
    final router = await _pumpMaterialSplit(tester);
    expect(defaultTargetPlatform, TargetPlatform.android);

    await tester.predictiveBack();

    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
    expect(find.text('Rooms:0'), findsOneWidget);
    expect(find.text('Room 1:0'), findsOneWidget);
  }, variant: android);

  testWidgets('the back button in columns closes the deepest one', (
    tester,
  ) async {
    final router = await _pumpMaterialSplit(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
  });

  testWidgets('the iOS swipe in a narrow split reveals the real page '
      'below', (tester) async {
    final router = await _pumpMaterialSplit(tester, width: 400);

    await tester.iosEdgeSwipe();

    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
    expect(find.text('Room 1:0'), findsOneWidget);
  }, variant: iOS);
}
