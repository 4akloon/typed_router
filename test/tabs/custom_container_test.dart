// Tabs whose builder lays out shell.navigators in a container of its own.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/testing.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/back_fixtures.dart';
import '../support/container_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/tabs_fixtures.dart';

void main() {
  testWidgets('a custom container shows the active branch; an unvisited one '
      'is empty', (tester) async {
    final capture = ShellCapture();
    await pumpContainerApp(
      tester,
      containerRoutes(capture, offstageContainer),
      rooms,
    );

    expect(capture.current.navigators, hasLength(2));
    expect(find.text('Rooms'), findsOneWidget);
    expect(find.text('Friends', skipOffstage: false), findsNothing);

    await settled(tester, () => capture.current.goBranch<FriendsBranch>());

    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Rooms'), findsNothing);
  });

  testWidgets('switching in a custom container keeps the screens', (
    tester,
  ) async {
    final capture = ShellCapture();
    final log = ScreenLog();
    final router = await pumpContainerApp(
      tester,
      containerRoutes(capture, offstageContainer, log: log),
      room7,
    );

    await settled(tester, () => capture.current.goBranch<FriendsBranch>());
    await settled(tester, () => capture.current.goBranch<RoomsBranch>());

    expect(router.state.routes, const [rooms, room7]);
    expect(find.text('Room 7'), findsOneWidget);
    expect(log.created.where((text) => text == 'Room 7'), hasLength(1));
  });

  testWidgets('a PageView of navigators, bound to the shell, switches '
      'branches and keeps the one scrolled away', (tester) async {
    final capture = ShellCapture();
    final log = ScreenLog();
    final pages = PageController();
    addTearDown(pages.dispose);
    final router = await pumpContainerApp(
      tester,
      containerRoutes(
        capture,
        (shell) => PageView(
          controller: pages,
          onPageChanged: shell.goBranchAt,
          children: shell.navigators,
        ),
        log: log,
      ),
      room7,
    );

    await settled(tester, () => pages.jumpToPage(1));
    expect(router.state.top, friends);
    expect(find.text('Friends'), findsOneWidget);

    await settled(tester, () => pages.jumpToPage(0));
    expect(router.state.top, room7);
    expect(find.text('Room 7'), findsOneWidget);
    expect(log.created.where((text) => text == 'Room 7'), hasLength(1));
  });

  testWidgets('navigators are not muted for a custom container', (
    tester,
  ) async {
    final capture = ShellCapture();
    await pumpContainerApp(
      tester,
      containerRoutes(capture, offstageContainer, friends: spinningFriends),
      friends,
    );

    capture.current.goBranch<RoomsBranch>();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Hiding is the container's job; this one only puts it offstage.
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('predictive back pops only the active branch when two are '
      'shown', (tester) async {
    final capture = ShellCapture();
    final router = TypedRouter(
      routes: containerRoutes(
        capture,
        (shell) => Row(
          children: [
            for (final navigator in shell.navigators)
              Expanded(child: navigator),
          ],
        ),
      ),
      initialRoute: ann,
      pageFactory: const MaterialPageFactory(),
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: predictiveBackTheme),
    );
    await settled(tester, () => router.go(room7));

    await tester.predictiveBack();

    expect(
      router.state.toString(),
      '{*RoomsBranch: [RoomsRoute()] | '
      'FriendsBranch: [FriendsRoute() > FriendRoute(ann)]}',
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
