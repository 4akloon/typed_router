// A rooms app on a split: rooms with a placeholder, a room, its players, a
// lobby over the whole split, rules over the whole app, and an account page
// outside the split.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import 'app_fixtures.dart';
import 'route_fixtures.dart';
import 'split_screens.dart';
import 'tabs_fixtures.dart';

export 'route_fixtures.dart';
export 'split_screens.dart';
export 'tabs_fixtures.dart' show ScreenLog;

const rooms = RoomsRoute();
const room1 = RoomRoute(RoomId(1));
const room2 = RoomRoute(RoomId(2));
const playerAnn = PlayerRoute(1, 'ann');
const playerBob = PlayerRoute(1, 'bob');
const lobby = LobbyRoute(1);

/// The split of the app; [columns] above 800 logical pixels, one below.
SplitNode<NoParentRoute> roomsSplit(
  ScreenLog log, {
  int columns = 2,
  Widget Function(BuildContext context, NavigationState state, SplitView split)?
  builder,
}) => SplitNode<NoParentRoute>(
  maximumColumns: (size) => size.width >= 800 ? columns : 1,
  builder: builder,
  children: [
    RouteNode<RoomsRoute>(
      build: (context, rooms) => CountingScreen('Rooms', log),
      placeholder: (context, rooms) => const Text('Pick a room'),
      children: [
        RouteNode<RoomRoute>(
          build: (context, room) =>
              CountingScreen('Room ${room.id.value}', log),
          children: [
            RouteNode<PlayerRoute>(
              build: (context, player) =>
                  CountingScreen('Player ${player.name}', log),
            ).withParent((player) => RoomRoute(RoomId(player.roomId))),
            RouteNode<LobbyRoute>(
              build: (context, lobby) => CountingScreen('Lobby', log),
              splitPresentation: SplitPresentation.cover,
            ).withParent((lobby) => RoomRoute(RoomId(lobby.roomId))),
          ],
        ).withParent((room) => rooms),
        RouteNode<RulesRoute>(
          build: (context, rules) => const Text('Rules'),
          parentNavigatorSlot: NavigatorSlot.root,
        ).withParent((rules) => rooms),
      ],
    ),
  ],
);

/// A router over [roomsSplit] and an account page, in a window [width]
/// logical pixels wide; disposed when the test ends.
Future<TypedRouter> pumpSplitApp(
  WidgetTester tester,
  TypedRoute<Object?> initialRoute, {
  ScreenLog? log,
  int columns = 2,
  double width = 1000,
  Widget Function(BuildContext context, NavigationState state, SplitView split)?
  builder,
}) async {
  setWindowWidth(tester, width);
  final router = TypedRouter(
    routes: [
      roomsSplit(log ?? ScreenLog(), columns: columns, builder: builder),
      RouteNode<AccountRoute>(
        build: (context, account) => const Text('Account'),
      ),
    ],
    initialRoute: initialRoute,
    pageFactory: const TestPageFactory(),
  );
  addTearDown(router.dispose);
  await pumpWidgetsRouter(tester, router);
  await tester.pumpAndSettle();
  return router;
}

/// Makes the window [width] logical pixels wide and 600 high.
void setWindowWidth(WidgetTester tester, double width) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 600);
  addTearDown(tester.view.reset);
}

/// Changes the window's width and lets the frame settle.
Future<void> resizeWindow(WidgetTester tester, double width) {
  setWindowWidth(tester, width);
  return tester.pumpAndSettle();
}

/// Taps the screen labelled [label].
Future<void> tapScreen(WidgetTester tester, String label) async {
  await tester.tap(find.textContaining('$label:'));
  await tester.pump();
}

/// The on-screen rectangle of the text starting with [text].
Rect rectOf(WidgetTester tester, String text) =>
    tester.getRect(find.textContaining(text));

/// The navigator holding the screen labelled [label].
NavigatorState navigatorOf(WidgetTester tester, String label) => Navigator.of(
  tester.element(find.textContaining('$label:', skipOffstage: false)),
);
