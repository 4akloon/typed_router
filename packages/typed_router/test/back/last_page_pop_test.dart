// A native pop that would leave a navigator empty keeps the page, made anew;
// the state and the screen agree, and the leaving route shares no key with
// it.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/tabs_fixtures.dart';

void main() {
  testWidgets('a native pop of the only root page keeps it on screen', (
    tester,
  ) async {
    final router = appRouter(rooms);
    await pumpWidgetsRouter(tester, router);
    final notifications = NotificationCounter(router);

    Navigator.of(tester.element(find.text('Rooms'))).pop('ignored');
    await tester.pumpAndSettle();

    expect(router.state.routes, const [rooms]);
    expect(find.text('Rooms'), findsOneWidget);
    // The page is made anew: one notification, the routes unchanged.
    expect(notifications.count, 1);
  });

  testWidgets('a native pop of a tab root keeps it when the tabs are the '
      'only page', (tester) async {
    final router = await pumpTabsApp(tester, rooms);

    Navigator.of(tester.element(find.text('Rooms'))).pop();
    await tester.pumpAndSettle();

    expect(router.state.toString(), '{*RoomsBranch: [RoomsRoute()]}');
    expect(find.text('Tab 0'), findsOneWidget);
    expect(find.text('Rooms'), findsOneWidget);
  });

  testWidgets('a native pop of a tab root closes tabs pushed over a page, '
      'as before', (tester) async {
    final router = await pumpTabsApp(tester, const AccountRoute());
    await settled(tester, () => router.push(rooms).ignore());

    Navigator.of(tester.element(find.text('Rooms'))).pop();
    await tester.pumpAndSettle();

    expect(router.state.routes, const [AccountRoute()]);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Rooms', skipOffstage: false), findsNothing);
  });

  testWidgets('app rebuild during the exit animation of the only root page', (
    tester,
  ) async {
    final router = appRouter(rooms);
    late StateSetter rebuild;
    var color = const Color(0xFF000000);
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          return WidgetsApp.router(routerConfig: router, color: color);
        },
      ),
    );

    Navigator.of(tester.element(find.text('Rooms'))).pop();
    await tester.pump(const Duration(milliseconds: 100));
    rebuild(() => color = const Color(0xFF111111));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Rooms'), findsOneWidget);
  });

  testWidgets('dispose during the exit animation', (tester) async {
    final router = appRouter(rooms);
    await pumpWidgetsRouter(tester, router);

    Navigator.of(tester.element(find.text('Rooms'))).pop();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('two pops in a row on the only root page', (tester) async {
    final router = appRouter(rooms);
    await pumpWidgetsRouter(tester, router);

    Navigator.of(tester.element(find.text('Rooms'))).pop();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Rooms'))).pop();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Rooms'), findsOneWidget);
  });

  testWidgets('a native pop of the tabs page, the only root page, brings the '
      'tabs back with their screens anew', (tester) async {
    final log = ScreenLog();
    final router = await pumpTabsApp(tester, rooms, log: log);
    await settled(tester, () => router.push(room7).ignore());

    Navigator.of(tester.element(find.text('Tab 0'))).pop();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      router.state.toString(),
      '{*RoomsBranch: [RoomsRoute() > RoomRoute(RoomId(7))]}',
    );
    expect(find.text('Tab 0'), findsOneWidget);
    expect(find.text('Room 7'), findsOneWidget);
    expect(log.created.where((text) => text == 'Room 7'), hasLength(2));
  });
}
