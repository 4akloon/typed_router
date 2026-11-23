// onExit and the other operations: each one that removes the page asks, and
// a refused one changes nothing.

import 'package:flutter_test/flutter_test.dart';

import '../support/exit_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/tabs_fixtures.dart';

void main() {
  testWidgets('a refused replace, pushReplacement and pushAndRemoveUntil '
      'complete with null and keep the page', (tester) async {
    final log = ExitLog()..answer = (route) => false;
    final router = await pumpExitApp(tester, log);

    final replaced = ResultProbe(router.replace(room8));
    final pushedReplacement = ResultProbe(router.pushReplacement(room8));
    final pushedAlone = ResultProbe(
      router.pushAndRemoveUntil(account, (route) => false),
    );
    await tester.pumpAndSettle();

    expect(log.asked, const [room7, room7, room7]);
    expect(replaced.completions, [null]);
    expect(pushedReplacement.completions, [null]);
    expect(pushedAlone.completions, [null]);
    expect(router.state.routes, const [rooms, room7]);
    expect(find.text('Room 7'), findsOneWidget);
  });

  testWidgets('replace, pushReplacement, pop, popUntil and '
      'pushAndRemoveUntil ask onExit', (tester) async {
    final log = ExitLog()..answer = (route) => false;
    final router = await pumpExitApp(tester, log);
    final operations = <String, void Function()>{
      'replace in place': () => router.replace(room8).ignore(),
      'pushReplacement': () => router.pushReplacement(room8).ignore(),
      'pop': router.pop,
      'popUntil': () => router.popUntil((route) => route == rooms),
      'pushAndRemoveUntil': () =>
          router.pushAndRemoveUntil(room8, (route) => route == rooms).ignore(),
    };

    for (final MapEntry(key: name, value: operation) in operations.entries) {
      log.asked.clear();
      operation();
      expect(log.asked, const [room7], reason: name);
      expect(router.state.routes, const [rooms, room7], reason: name);
    }

    log.answer = (route) => true;
    router.replace(room8).ignore();
    expect(router.state.routes, const [rooms, room8]);
  });

  testWidgets('a replace into another level and a branch reset ask onExit', (
    tester,
  ) async {
    final log = ExitLog()..answer = (route) => false;
    final router = await pumpExitApp(tester, log, routes: exitTabsRoutes(log));

    router.replace(account).ignore();
    shellOf(tester).resetBranchAt(0);
    await tester.pumpAndSettle();

    expect(log.asked, const [room7, room7]);
    expect(router.state.routes, const [rooms, room7]);

    log.answer = (route) => true;
    await settled(tester, () => shellOf(tester).resetBranchAt(0));
    expect(router.state.routes, const [rooms]);
  });

  testWidgets('a refused pop keeps the push waiting, and a later pop '
      'completes it with its result', (tester) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log);
    final note = ResultProbe(router.push(editNote));
    await tester.pumpAndSettle();

    log.answer = (route) => false;
    router.pop('first');
    await tester.pumpAndSettle();
    expect(note.isCompleted, isFalse);
    expect(router.state.routes, const [rooms, room7, editNote]);

    log.answer = (route) => true;
    router.pop('second');
    await tester.pumpAndSettle();
    expect(note.completions, ['second']);
    expect(router.state.routes, const [rooms, room7]);
  });

  testWidgets('the result of a refused pop is not kept for a later exit', (
    tester,
  ) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log);
    final note = ResultProbe(router.push(editNote));
    await tester.pumpAndSettle();
    log.answer = (route) => false;
    router.pop('refused');

    log.answer = (route) => true;
    router.go(room7);
    await tester.pumpAndSettle();

    expect(note.completions, [null]);
    expect(router.state.routes, const [rooms, room7]);
  });
}
