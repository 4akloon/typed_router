// While onExit waits: a second back asks once, and a change that does not go
// through the operations drops the waiting one.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router_test/typed_router_test.dart';

import '../support/exit_fixtures.dart';
import '../support/operation_fixtures.dart';

void main() {
  testWidgets('a second back while onExit waits asks once and pops once', (
    tester,
  ) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log);
    router.push(editNote).ignore();
    await tester.pumpAndSettle();
    final answer = log.answerLater();

    await tester.systemBack();
    await tester.systemBack();
    expect(log.asked, const [editNote]);

    answer.complete(true);
    await tester.pumpAndSettle();
    expect(router.state.routes, const [rooms, room7]);
    expect(find.text('Room 7'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('a re-check that changes the stack drops the waiting '
      'operation', (tester) async {
    final log = ExitLog();
    final isBanned = ValueNotifier(false);
    addTearDown(isBanned.dispose);
    final router = await pumpExitApp(
      tester,
      log,
      refreshListenable: isBanned,
      redirect: (context, target) =>
          isBanned.value && target.top != account ? account : null,
    );
    final answer = log.answerLater();
    final waiting = ResultProbe(router.pushReplacement(room8));

    isBanned.value = true;
    await tester.pump();
    expect(router.state.routes, const [account]);
    expect(waiting.completions, [null]);

    answer.complete(true);
    await tester.pumpAndSettle();
    expect(router.state.routes, const [account]);
  });

  testWidgets('a pop outside the router drops the waiting operation', (
    tester,
  ) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log);
    final answer = log.answerLater();
    router.go(account);

    Navigator.of(tester.element(find.text('Room 7'))).pop();
    await tester.pumpAndSettle();
    expect(router.state.routes, const [rooms]);

    answer.complete(true);
    await tester.pumpAndSettle();
    expect(router.state.routes, const [rooms]);
    expect(find.text('Rooms'), findsOneWidget);
  });

  for (final (name, answer) in <(String, FutureOr<bool> Function(bool))>[
    ('a synchronous', (value) => value),
    ('a Future', Future<bool>.value),
  ]) {
    testWidgets('a re-check the hook starts wins over the navigation, with '
        '$name answer', (tester) async {
      final log = ExitLog();
      final isBanned = ValueNotifier(false);
      addTearDown(isBanned.dispose);
      final router = await pumpExitApp(
        tester,
        log,
        refreshListenable: isBanned,
        redirect: (context, target) =>
            isBanned.value && target.top != account ? account : null,
      );
      log.answer = (route) {
        isBanned.value = true;
        return answer(true);
      };

      router.go(rooms);
      await tester.pumpAndSettle();

      expect(router.state.routes, const [account]);
      expect(find.text('Account'), findsOneWidget);
    });
  }

  testWidgets('a waiting navigation is re-checked when it commits, so the '
      'guard wins', (tester) async {
    final log = ExitLog();
    final isBanned = ValueNotifier(false);
    addTearDown(isBanned.dispose);
    final router = await pumpExitApp(
      tester,
      log,
      refreshListenable: isBanned,
      redirect: (context, target) =>
          isBanned.value && target.top == account ? room8 : null,
    );
    final answer = log.answerLater();
    router.go(account);

    isBanned.value = true;
    await tester.pump();
    expect(router.state.routes, const [rooms, room7]);

    answer.complete(true);
    await tester.pumpAndSettle();
    expect(router.state.routes, const [rooms, room8]);
    expect(find.text('Room 8'), findsOneWidget);
  });
}
