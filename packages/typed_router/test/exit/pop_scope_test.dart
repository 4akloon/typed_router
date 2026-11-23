// A page with onExit and its own PopScope or app bar: BackButton and
// maybePop ask onExit; the page's PopScope decides first, as in go_router.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';
import 'package:typed_router_test/typed_router_test.dart';

import '../support/exit_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';

final android = TargetPlatformVariant.only(TargetPlatform.android);

/// Rooms and an asking room with an app bar, inside [PopScope] with
/// [canPop]; every pop it hears is added to [attempts].
List<TreeNode<NoParentRoute>> _roomWithPopScope(
  ExitLog log, {
  required bool canPop,
  required List<bool> attempts,
}) => [
  RouteNode<RoomsRoute>(
    build: (context, rooms) => const Text('Rooms'),
    children: [
      RouteNode<RoomRoute>(
        build: (context, room) => PopScope<Object?>(
          canPop: canPop,
          onPopInvokedWithResult: (didPop, result) => attempts.add(didPop),
          child: Scaffold(appBar: AppBar(), body: const Text('Room 7')),
        ),
        onExit: (context, room, target) => log.ask(room, target),
      ).withParent((room) => const RoomsRoute()),
    ],
  ),
];

void main() {
  testWidgets('BackButton and Navigator.maybePop ask onExit', (tester) async {
    final log = ExitLog()..answer = (route) => false;
    final router = await pumpExitApp(
      tester,
      log,
      routes: _roomWithPopScope(log, canPop: true, attempts: []),
    );

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await Navigator.maybePop(tester.element(find.text('Room 7')));
    await tester.pumpAndSettle();

    expect(log.asked, const [room7, room7]);
    expect(router.state.routes, const [rooms, room7]);
  });

  testWidgets("the page's own PopScope with canPop false decides first", (
    tester,
  ) async {
    final log = ExitLog();
    final attempts = <bool>[];
    final router = await pumpExitApp(
      tester,
      log,
      routes: _roomWithPopScope(log, canPop: false, attempts: attempts),
    );

    await tester.systemBack();

    expect(attempts, [false]);
    expect(log.asked, isEmpty);
    expect(router.state.routes, const [rooms, room7]);
  }, variant: android);

  testWidgets("the page's own PopScope with canPop true lets onExit ask", (
    tester,
  ) async {
    final log = ExitLog();
    final attempts = <bool>[];
    final router = await pumpExitApp(
      tester,
      log,
      routes: _roomWithPopScope(log, canPop: true, attempts: attempts),
    );

    await tester.systemBack();

    // Refused while onExit is asked, then popped by the router.
    expect(log.asked, const [room7]);
    expect(attempts, [false, true]);
    expect(router.state.routes, const [rooms]);
  }, variant: android);
}
