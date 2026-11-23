// An onExit that answers with a Future: the operation waits, and a newer
// navigation or dispose meanwhile wins.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';

import '../support/exit_fixtures.dart';
import '../support/material_page_factory.dart';
import '../support/operation_fixtures.dart';

void main() {
  testWidgets('an operation waits for a Future answer and commits on true', (
    tester,
  ) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log);
    final answer = log.answerLater();

    final note = ResultProbe(router.pushReplacement(editNote));
    await tester.pumpAndSettle();
    expect(router.state.routes, const [rooms, room7]);
    expect(find.text('Room 7'), findsOneWidget);

    answer.complete(true);
    await tester.pumpAndSettle();
    expect(router.state.routes, const [rooms, editNote]);
    expect(find.text('Edit note'), findsOneWidget);
    expect(note.isCompleted, isFalse);

    log.answer = (route) => true;
    router.pop('Buy milk');
    await tester.pumpAndSettle();
    expect(note.completions, ['Buy milk']);
  });

  testWidgets('an operation that waits stays on false', (tester) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log);
    final answer = log.answerLater();
    final notifications = NotificationCounter(router);

    final replaced = ResultProbe(router.pushReplacement(room8));
    answer.complete(false);
    await tester.pumpAndSettle();

    expect(router.state.routes, const [rooms, room7]);
    expect(replaced.completions, [null]);
    expect(notifications.count, 0);
  });

  testWidgets('a newer navigation that keeps the page wins, and the late '
      'answer changes nothing', (tester) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log);
    final answer = log.answerLater();
    final waiting = ResultProbe(router.pushReplacement(account));

    router.push(room8).ignore();
    expect(router.state.routes, const [rooms, room7, room8]);
    await tester.pump();
    expect(waiting.completions, [null]);

    answer.complete(true);
    await tester.pumpAndSettle();
    expect(router.state.routes, const [rooms, room7, room8]);
    expect(find.text('Room 8'), findsOneWidget);
  });

  testWidgets('a navigation that changes nothing keeps the waiting one', (
    tester,
  ) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log);
    final answer = log.answerLater();
    final waiting = ResultProbe(router.pushReplacement(account));

    router.go(room7);
    await tester.pump();
    expect(waiting.isCompleted, isFalse);

    answer.complete(true);
    await tester.pumpAndSettle();
    expect(router.state.routes, const [rooms, account]);
  });

  testWidgets('a newer navigation that removes the page takes over the open '
      'question', (tester) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log);
    final answer = log.answerLater();
    final overtaken = ResultProbe(router.pushReplacement(account));

    router.go(room8);
    expect(log.asked, const [room7]);
    expect(router.state.routes, const [rooms, room7]);
    await tester.pump();
    expect(overtaken.completions, [null]);

    answer.complete(true);
    await tester.pumpAndSettle();
    expect(log.asked, const [room7]);
    expect(router.state.routes, const [rooms, room8]);
    expect(find.text('Room 8'), findsOneWidget);
  });

  testWidgets('dispose drops the waiting operation and its push completes '
      'with null', (tester) async {
    final log = ExitLog();
    final router = TypedRouter(
      routes: exitRoutes(log),
      initialRoute: room7,
      pageFactory: const MaterialPageFactory(),
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    final answer = log.answerLater();
    final waiting = ResultProbe(router.pushReplacement(account));

    router.dispose();
    await tester.pump();
    expect(waiting.completions, [null]);

    answer.complete(true);
    await tester.pumpWidget(const SizedBox());
    expect(router.state.routes, const [rooms, room7]);
  });
}
