// Material columns with app bars for the back button tests of a split.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';

import 'back_fixtures.dart';
import 'split_fixtures.dart';

/// A page titled [title] with an app bar.
Widget _page(String title) => Scaffold(
  appBar: AppBar(title: Text(title)),
  body: const SizedBox(),
);

/// The room page; room 9 refuses back and room 8 allows it through a
/// `PopScope`, each adding every attempt to [attempts].
Widget _room(RoomRoute room, List<bool> attempts) => switch (room.id.value) {
  final number && (8 || 9) => PopScope<Object?>(
    canPop: number == 8,
    onPopInvokedWithResult: (didPop, result) => attempts.add(didPop),
    child: _page('Room $number'),
  ),
  final number => _page('Room $number'),
};

/// Rooms > room > player in a split, three columns from 800 logical
/// pixels, a stack below. Room 9 and player eve refuse back, room 8 lets
/// it through a `PopScope`; their attempts go to the list given.
List<TreeNode<NoParentRoute>> columnBackRoutes(List<bool> attempts) => [
  SplitNode<NoParentRoute>(
    maximumColumns: (size) => size.width >= 800 ? 3 : 1,
    children: [
      RouteNode<RoomsRoute>(
        build: (context, rooms) => _page('Rooms'),
        children: [
          RouteNode<RoomRoute>(
            build: (context, room) => _room(room, attempts),
            children: [
              RouteNode<PlayerRoute>(
                build: (context, player) => _player(player, attempts),
              ).withParent((player) => RoomRoute(RoomId(player.roomId))),
            ],
          ).withParent((room) => const RoomsRoute()),
        ],
      ),
    ],
  ),
];

/// The player page; eve refuses back, adding each attempt to [attempts].
Widget _player(PlayerRoute player, List<bool> attempts) =>
    switch (player.name) {
      'eve' => PopScope<Object?>(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => attempts.add(didPop),
        child: _page('Player eve'),
      ),
      final name => _page('Player $name'),
    };

/// Rooms | a shell around the room, framed by 'Shell frame' | the player,
/// shown in the split's own navigator.
List<TreeNode<NoParentRoute>> shellColumnRoutes() {
  final splitSlot = NavigatorSlot();
  return [
    SplitNode<NoParentRoute>(
      maximumColumns: (size) => 3,
      navigatorSlot: splitSlot,
      children: [
        RouteNode<RoomsRoute>(
          build: (context, rooms) => _page('Rooms'),
          children: [
            ShellNode<RoomsRoute>(
              builder: (context, state, navigator) => Column(
                children: [
                  const Text('Shell frame'),
                  Expanded(child: navigator),
                ],
              ),
              children: [
                RouteNode<RoomRoute>(
                  build: (context, room) => _page('Room ${room.id.value}'),
                  children: [
                    RouteNode<PlayerRoute>(
                      build: (context, player) =>
                          _page('Player ${player.name}'),
                      parentNavigatorSlot: splitSlot,
                    ).withParent((player) => RoomRoute(RoomId(player.roomId))),
                  ],
                ).withParent((room) => const RoomsRoute()),
              ],
            ),
          ],
        ),
      ],
    ),
  ];
}

/// A Material app over [routes] in a window [width] logical pixels wide,
/// started at [initialRoute]; disposed when the test ends.
Future<TypedRouter> pumpColumns(
  WidgetTester tester,
  List<TreeNode<NoParentRoute>> routes,
  TypedRoute<Object?> initialRoute, {
  double width = 1200,
}) async {
  setWindowWidth(tester, width);
  final router = TypedRouter(
    routes: routes,
    initialRoute: initialRoute,
    pageFactory: const MaterialPageFactory(),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(routerConfig: router, theme: predictiveBackTheme),
  );
  await tester.pumpAndSettle();
  return router;
}

/// The back button in the app bar titled [title].
Finder backButtonOf(String title) => find.descendant(
  of: find.widgetWithText(AppBar, title),
  matching: find.byType(BackButton),
);

/// Whether the page showing [text] handles a pop itself (a local history
/// entry), on screen or not.
bool popsInternally(WidgetTester tester, String text) =>
    ModalRoute.of(
      tester.element(find.text(text, skipOffstage: false)),
    )?.willHandlePopInternally ??
    false;

/// The navigator holding the page titled [title].
NavigatorState navigatorTitled(WidgetTester tester, String title) =>
    Navigator.of(tester.element(find.text(title, skipOffstage: false)));
