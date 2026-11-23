// Push and removal across a shell.

import 'package:flutter_test/flutter_test.dart';

import '../support/shell_fixtures.dart';
import '../support/tree_fixtures.dart';

void main() {
  testWidgets('push of a child of the shell on screen goes into its '
      'navigator', (tester) async {
    final router = await pumpShellApp(tester, user1);

    await settleAfter(tester, () => router.push(user2).ignore());

    expect(
      router.state.toString(),
      '[UsersRoute() > UserRoute(u1) > UserRoute(u2)]',
    );
    expect(rootPageCount(router), 1);
    expect(navigatorShowing(tester, 'User u2').widget.pages, hasLength(3));
    expect(find.text('User u2'), findsOneWidget);
    expect(find.text('User u1'), findsNothing);
  });

  testWidgets('push of a route outside the shell goes onto the root above '
      'it', (tester) async {
    final router = await pumpShellApp(tester, user1);

    await settleAfter(tester, () => router.push(account).ignore());

    expect(
      router.state.toString(),
      '[UsersRoute() > UserRoute(u1)] > AccountRoute()',
    );
    expect(rootPageCount(router), 2);
    expect(navigatorShowing(tester, 'Account'), same(router.navigator));
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('User u1'), findsNothing);
  });

  testWidgets('push of a child of a shell covered by another page starts a '
      'new shell', (tester) async {
    final router = await pumpShellApp(tester, user1);
    final firstShell = navigatorShowing(tester, 'User u1');
    await settleAfter(tester, () => router.push(account).ignore());

    await settleAfter(tester, () => router.push(user2).ignore());

    expect(
      router.state.toString(),
      '[UsersRoute() > UserRoute(u1)] > AccountRoute() > [UserRoute(u2)]',
    );
    expect(rootPageCount(router), 3);
    expect(navigatorShowing(tester, 'User u2'), isNot(same(firstShell)));
    expect(find.text('User u2'), findsOneWidget);
    expect(find.text('Account'), findsNothing);
  });

  testWidgets('pop of the last child removes the shell', (tester) async {
    final router = await pumpShellApp(tester, account);
    await settleAfter(tester, () => router.push(user2).ignore());
    expect(rootPageCount(router), 2);

    await settleAfter(tester, router.pop<void>);

    expect(router.state.toString(), 'AccountRoute()');
    expect(rootPageCount(router), 1);
    expect(find.text('Account'), findsOneWidget);
  });

  testWidgets('popUntil, replace and pushAndRemoveUntil cross the shell '
      'boundary', (tester) async {
    final router = await pumpShellApp(tester, user1);
    await settleAfter(tester, () => router.push(account).ignore());

    await settleAfter(
      tester,
      () => router.popUntil((route) => route is UserRoute),
    );
    expect(router.state.toString(), '[UsersRoute() > UserRoute(u1)]');
    expect(find.text('User u1'), findsOneWidget);

    await settleAfter(tester, () => router.replace(user2).ignore());
    expect(router.state.toString(), '[UsersRoute() > UserRoute(u2)]');
    expect(find.text('User u2'), findsOneWidget);

    await settleAfter(
      tester,
      () => router
          .pushAndRemoveUntil(account, (route) => route is UsersRoute)
          .ignore(),
    );
    expect(router.state.toString(), '[UsersRoute()] > AccountRoute()');
    expect(find.text('Account'), findsOneWidget);
  });
}
