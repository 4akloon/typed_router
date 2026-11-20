// The library leaves Esc alone in a split, as Navigator does for pages.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/split_fixtures.dart';

void main() {
  testWidgets('Esc in a split closes nothing', (tester) async {
    setWindowWidth(tester, 1200);
    final router = TypedRouter(
      routes: [roomsSplit(ScreenLog())],
      initialRoute: room1,
      pageFactory: const MaterialPageFactory(),
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
  });
}
