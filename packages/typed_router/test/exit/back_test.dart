// Back on a page whose node has onExit: the back button asks it, in a shell
// and a tab too and on the only page; a dialog closes first.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router_test/typed_router_test.dart';

import '../support/back_fixtures.dart';
import '../support/exit_fixtures.dart';
import '../support/operation_fixtures.dart';

final android = TargetPlatformVariant.only(TargetPlatform.android);

void main() {
  testWidgets('system back asks onExit and pops on true only', (tester) async {
    final log = ExitLog()..answer = (route) => false;
    final router = await pumpExitApp(tester, log);

    await tester.systemBack();
    expect(log.asked, const [room7]);
    expect(router.state.routes, const [rooms, room7]);
    expect(find.text('Room 7'), findsOneWidget);

    log.answer = (route) => true;
    await tester.systemBack();
    expect(router.state.routes, const [rooms]);
    expect(find.text('Rooms'), findsOneWidget);
  }, variant: android);

  testWidgets('back on the only page asks onExit and closes the app on '
      'true, as go_router', (tester) async {
    final log = ExitLog()..answer = (route) => false;
    final router = await pumpExitApp(tester, log, initialRoute: editNote);
    final platform = PlatformNavigationLog(tester);

    await tester.systemBack();
    expect(log.asked, const [editNote]);
    expect(log.targets.single.routes, const [editNote]);
    expect(platform.closedApp, isFalse);

    log.answer = (route) => true;
    await tester.systemBack();
    expect(platform.closedApp, isTrue);
    expect(router.state.routes, const [editNote]);
  }, variant: android);

  testWidgets('back closes a dialog above the page without asking', (
    tester,
  ) async {
    final log = ExitLog()..answer = (route) => false;
    final router = await pumpExitApp(tester, log);
    final dialog = await openDialogOver(tester, 'Room 7');

    await tester.systemBack();

    expect(find.text('Dialog'), findsNothing);
    expect(dialog.completions, [null]);
    expect(log.asked, isEmpty);
    expect(router.state.routes, const [rooms, room7]);
  }, variant: android);

  for (final (name, routes) in [
    ('a shell', exitShellRoutes),
    ('a tab', exitTabsRoutes),
  ]) {
    testWidgets('back reaches onExit of a page in $name', (tester) async {
      final log = ExitLog()..answer = (route) => false;
      final router = await pumpExitApp(tester, log, routes: routes(log));

      await tester.systemBack();
      expect(log.asked, const [room7]);
      expect(router.state.routes, const [rooms, room7]);

      log.answer = (route) => true;
      await tester.systemBack();
      expect(router.state.routes, const [rooms]);
      expect(find.text('Rooms'), findsOneWidget);
    }, variant: android);
  }

  testWidgets('maybePop in a navigator a root page covers does not ask', (
    tester,
  ) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log, routes: exitShellRoutes(log));
    router.push(account).ignore();
    await tester.pumpAndSettle();

    await Navigator.maybePop(
      tester.element(find.text('Room 7', skipOffstage: false)),
    );
    await tester.pumpAndSettle();

    expect(log.asked, isEmpty);
    expect(router.state.routes, const [rooms, room7, account]);
  });
}
