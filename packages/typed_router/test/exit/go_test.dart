// onExit and go: who is asked, with what, and in which order.

import 'package:flutter_test/flutter_test.dart';

import '../support/exit_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/tabs_fixtures.dart';

void main() {
  testWidgets('go asks onExit of the page it removes and commits at once on '
      'true', (tester) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log);

    router.go(account);

    expect(log.asked, const [room7]);
    expect(log.targets.single.routes, const [account]);
    expect(router.state.routes, const [account]);
    await tester.pumpAndSettle();
    expect(find.text('Account'), findsOneWidget);
  });

  testWidgets('a synchronous false keeps the page and notifies nobody', (
    tester,
  ) async {
    final log = ExitLog()..answer = (route) => false;
    final router = await pumpExitApp(tester, log);
    final notifications = NotificationCounter(router);

    router.go(account);
    await tester.pumpAndSettle();

    expect(log.asked, const [room7]);
    expect(router.state.routes, const [rooms, room7]);
    expect(notifications.count, 0);
    expect(find.text('Room 7'), findsOneWidget);
  });

  testWidgets('several leaving pages are asked from the top, and the first '
      'false stops', (tester) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log);
    router.push(editNote).ignore();
    await tester.pumpAndSettle();

    log.answer = (route) => route != editNote;
    router.go(account);
    expect(log.asked, const [editNote]);

    log.asked.clear();
    log.answer = (route) => route != room7;
    router.go(account);
    expect(log.asked, const [editNote, room7]);
    expect(router.state.routes, const [rooms, room7, editNote]);

    log.asked.clear();
    log.answer = (route) => true;
    router.go(account);
    expect(log.asked, const [editNote, room7]);
    expect(router.state.routes, const [account]);
  });

  testWidgets('onExit sees the target after redirects', (tester) async {
    final log = ExitLog();
    final router = await pumpExitApp(
      tester,
      log,
      redirect: (context, target) => target.top == room8 ? account : null,
    );

    router.go(room8);

    expect(log.targets.single.routes, const [account]);
    expect(router.state.routes, const [account]);
  });

  testWidgets('push over the page and go to the same route do not ask', (
    tester,
  ) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log);

    router.push(editNote).ignore();
    await tester.pumpAndSettle();
    router.go(room7);
    await tester.pumpAndSettle();

    expect(log.asked, const [editNote]);
    expect(router.state.routes, const [rooms, room7]);

    log.asked.clear();
    router.go(room7);
    expect(log.asked, isEmpty);
  });

  testWidgets('switching to another tab keeps the page and does not ask', (
    tester,
  ) async {
    final log = ExitLog();
    final router = await pumpExitApp(
      tester,
      log,
      routes: exitTabsRoutes(log),
    );

    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());
    await settled(tester, () => shellOf(tester).goBranch<RoomsBranch>());

    expect(log.asked, isEmpty);
    expect(router.state.routes, const [rooms, room7]);
    expect(find.text('Room 7'), findsOneWidget);
  });
}
