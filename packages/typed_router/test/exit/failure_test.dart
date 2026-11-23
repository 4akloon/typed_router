// An onExit that fails, and one that navigates.

import 'package:flutter_test/flutter_test.dart';

import '../support/exit_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/transaction_fixtures.dart';

void main() {
  // testWidgets installs its own handler when the test starts and checks it
  // when the body ends, so each body collects and restores.
  testWidgets('a throwing onExit or a failed Future is reported and refuses', (
    tester,
  ) async {
    final log = ExitLog()..answer = (route) => throw StateError('thrown');
    final router = await pumpExitApp(tester, log);
    final reportedErrors = ReportedErrors()..start();

    final thrown = ResultProbe(router.pushReplacement(account));
    log.answer = (route) => Future.error(StateError('failed'));
    final failed = ResultProbe(router.pushReplacement(account));
    await tester.pumpAndSettle();
    reportedErrors.stop();

    expect(thrown.completions, [null]);
    expect(failed.completions, [null]);
    expect(router.state.routes, const [rooms, room7]);
    expect(
      reportedErrors.details.map((details) => details.exception.toString()),
      ['Bad state: thrown', 'Bad state: failed'],
    );
    for (final details in reportedErrors.details) {
      expect(details.library, 'typed_router');
      expect(details.context.toString(), contains('$room7'));
    }
  });

  testWidgets('navigating from inside onExit fails in debug', (tester) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log);
    log.answer = (route) {
      router.go(room8);
      return true;
    };
    final reportedErrors = ReportedErrors()..start();

    router.go(account);
    reportedErrors.stop();

    expect(reportedErrors.details.single.exception, isA<AssertionError>());
    expect(router.state.routes, const [rooms, room7]);
  });

  testWidgets('navigating from onExit after an await is a newer navigation', (
    tester,
  ) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log);
    log.answer = (route) async {
      await null;
      router.go(room8);
      return true;
    };
    final reportedErrors = ReportedErrors()..start();

    router.go(account);
    await tester.pumpAndSettle();
    reportedErrors.stop();

    expect(log.asked, const [room7]);
    expect(router.state.routes, const [rooms, room8]);
    expect(reportedErrors.details, isEmpty);
  });
}
