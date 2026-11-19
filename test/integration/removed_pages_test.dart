// Pages the navigator removes by itself leave the router state.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/back_gestures.dart';
import '../support/route_fixtures.dart';

const rooms = RoomsRoute();
const room7 = RoomRoute(RoomId(7));

Future<TypedRouter> pumpRoomOverRooms(
  WidgetTester tester, {
  ThemeData? theme,
}) async {
  final router = appRouter(room7, pageFactory: const MaterialPageFactory());
  await tester.pumpWidget(
    MaterialApp.router(routerConfig: router, theme: theme),
  );
  return router;
}

void main() {
  testWidgets('pages below keep their state when the top page is removed', (
    tester,
  ) async {
    final router = await pumpRoomOverRooms(tester);
    final roomsState = tester.state(
      find.byType(RoomsScreen, skipOffstage: false),
    );

    router.navigator?.pop();
    await tester.pumpAndSettle();

    expect(tester.state(find.byType(RoomsScreen)), same(roomsState));
  });

  testWidgets('Navigator.pop removes the top page from the state with one '
      'notification', (tester) async {
    final router = await pumpRoomOverRooms(tester);
    var notifications = 0;
    router.addListener(() => notifications++);

    router.navigator?.pop();
    await tester.pumpAndSettle();

    expect(router.state.routes, const [rooms]);
    expect(notifications, 1);
    expect(find.text('Rooms'), findsOneWidget);
    expect(find.text('Room 7', skipOffstage: false), findsNothing);
  });

  testWidgets(
    'an Android predictive back gesture removes the top page from the state',
    (tester) async {
      final router = await pumpRoomOverRooms(
        tester,
        theme: predictiveBackTheme,
      );

      await predictiveBack(tester);

      expect(router.state.routes, const [rooms]);
      expect(find.text('Rooms'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'an iOS edge swipe removes the top page from the state',
    (tester) async {
      final router = await pumpRoomOverRooms(tester);

      await iosEdgeSwipe(tester);

      expect(router.state.routes, const [rooms]);
      expect(find.text('Rooms'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
