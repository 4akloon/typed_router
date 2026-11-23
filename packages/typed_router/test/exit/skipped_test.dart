// What does not ask onExit: a page of a branch not on screen, a re-check of
// the stack, dispose, a native Navigator.pop, a router not shown.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';

import '../support/exit_fixtures.dart';
import '../support/material_page_factory.dart';
import '../support/operation_fixtures.dart';
import '../support/tabs_fixtures.dart';

void main() {
  testWidgets('go does not ask a page it removes from a branch not on '
      'screen, as go_router', (tester) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log, routes: exitTabsRoutes(log));
    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());

    await settled(tester, () => router.go(room8));

    expect(log.asked, isEmpty);
    expect(router.state.routes, const [rooms, room8]);
    expect(find.text('Room 8'), findsOneWidget);
  });

  testWidgets('a re-check of the stack removes the page without asking', (
    tester,
  ) async {
    final log = ExitLog()..answer = (route) => false;
    final isBanned = ValueNotifier(false);
    addTearDown(isBanned.dispose);
    final router = await pumpExitApp(
      tester,
      log,
      refreshListenable: isBanned,
      redirect: (context, target) =>
          isBanned.value && target.top != account ? account : null,
    );

    isBanned.value = true;
    await tester.pumpAndSettle();

    expect(log.asked, isEmpty);
    expect(router.state.routes, const [account]);
    expect(find.text('Account'), findsOneWidget);
  });

  testWidgets('dispose does not ask', (tester) async {
    final log = ExitLog();
    final router = TypedRouter(
      routes: exitRoutes(log),
      initialRoute: room7,
      pageFactory: const MaterialPageFactory(),
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    router.dispose();
    await tester.pumpWidget(const SizedBox());

    expect(log.asked, isEmpty);
  });

  testWidgets('Navigator.pop of the page does not ask, as it skips PopScope', (
    tester,
  ) async {
    final log = ExitLog()..answer = (route) => false;
    final router = await pumpExitApp(tester, log);

    Navigator.of(tester.element(find.text('Room 7'))).pop();
    await tester.pumpAndSettle();

    expect(log.asked, isEmpty);
    expect(router.state.routes, const [rooms]);
    expect(find.text('Rooms'), findsOneWidget);
  });

  test('a router not shown does not ask', () {
    final log = ExitLog()..answer = (route) => false;
    final router = TypedRouter(
      routes: exitRoutes(log),
      initialRoute: room7,
      pageFactory: const MaterialPageFactory(),
    );
    addTearDown(router.dispose);

    router.go(account);

    expect(log.asked, isEmpty);
    expect(router.state.routes, const [account]);
  });
}
