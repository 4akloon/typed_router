// The router shown by MaterialApp.router and WidgetsApp.router.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/material.dart';

import '../support/app_fixtures.dart';
import '../support/route_fixtures.dart';

void main() {
  testWidgets('MaterialApp.router shows the initial screen above its '
      'ancestors', (tester) async {
    final router = appRouter(
      const RoomRoute(RoomId(7)),
      pageFactory: const MaterialPageFactory(),
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Room 7'), findsOneWidget);
    expect(find.text('Rooms'), findsNothing);
    expect(find.text('Rooms', skipOffstage: false), findsOneWidget);
  });

  testWidgets('WidgetsApp.router with a widgets-only factory shows the same '
      'stack', (tester) async {
    final router = appRouter(const RoomRoute(RoomId(7)));

    await pumpWidgetsRouter(tester, router);

    expect(find.text('Room 7'), findsOneWidget);
    expect(find.text('Rooms', skipOffstage: false), findsOneWidget);
    expect(pageShowing(tester, 'Room 7'), isA<TestPage>());
  });

  testWidgets('a screen is built from its node with the typed route', (
    tester,
  ) async {
    final router = appRouter(const RoomRoute(RoomId(42)));

    await pumpWidgetsRouter(tester, router);

    expect(find.text('Room 42'), findsOneWidget);
    expect(
      ModalRoute.of(tester.element(find.text('Room 42')))?.isCurrent,
      isTrue,
    );
  });
}
