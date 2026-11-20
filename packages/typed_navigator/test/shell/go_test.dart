// Go into, within and out of a shell.

import 'package:flutter_test/flutter_test.dart';

import '../support/operation_fixtures.dart';
import '../support/shell_fixtures.dart';

void main() {
  testWidgets('go to a child of a shell builds the shell and the chain', (
    tester,
  ) async {
    final router = await pumpShellApp(tester, account);

    await settleAfter(tester, () => router.go(user1));

    expect(router.state.routes, const [users, user1]);
    expect(router.state.toString(), '[UsersRoute() > UserRoute(u1)]');
    expect(rootPageCount(router), 1);
    expect(find.text('User u1'), findsOneWidget);
  });

  testWidgets('go within a shell keeps the shell and its navigator', (
    tester,
  ) async {
    final log = FrameLog();
    final router = await pumpShellApp(tester, user1, log: log);
    final shellNavigator = navigatorShowing(tester, 'User u1');

    await settleAfter(tester, () => router.go(user2));

    expect(router.state.toString(), '[UsersRoute() > UserRoute(u2)]');
    expect(navigatorShowing(tester, 'User u2'), same(shellNavigator));
    expect(log.createdFrames, 1);
  });

  testWidgets('go outside a shell removes it and completes its pushes with '
      'null', (tester) async {
    final router = await pumpShellApp(tester, user1);
    final note = ResultProbe(router.push(editNote));
    await tester.pumpAndSettle();

    await settleAfter(tester, () => router.go(account));

    expect(router.state.toString(), 'AccountRoute()');
    expect(note.completions, [null]);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('User u1', skipOffstage: false), findsNothing);
  });
}
