// A shell, its navigator and its builder.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/shell_fixtures.dart';
import '../support/tree_fixtures.dart';

void main() {
  testWidgets('a shell shows its children in its own navigator', (
    tester,
  ) async {
    final router = await pumpShellApp(tester, user1);

    final shellNavigator = navigatorShowing(tester, 'User u1');
    expect(shellNavigator, isNot(same(router.navigator)));
    expect(shellNavigator.widget.pages, hasLength(2));
    expect(rootPageCount(router), 1);
    expect(find.text('User u1'), findsOneWidget);
  });

  testWidgets('a child of a shell builds a parent above the shell', (
    tester,
  ) async {
    final router = TypedRouter(
      routes: [
        RouteNode<UsersRoute>(
          build: (context, users) => const Text('Users'),
          children: [
            ShellNode<UsersRoute>(
              builder: (context, state, navigator) => navigator,
              children: [
                RouteNode<UserRoute>(
                  build: (context, user) => Text('User ${user.userId}'),
                ).withParent((user) => const UsersRoute()),
              ],
            ),
          ],
        ),
      ],
      initialRoute: user1,
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);

    expect(router.state.toString(), 'UsersRoute() > [UserRoute(u1)]');
    expect(rootPageCount(router), 2);
    expect(navigatorShowing(tester, 'User u1'), isNot(same(router.navigator)));
  });

  testWidgets('the shell builder sees the selected route', (tester) async {
    final router = await pumpShellApp(tester, users);
    expect(find.text('Selected: none'), findsOneWidget);

    await settleAfter(tester, () => router.go(user1));

    expect(find.text('Selected: u1'), findsOneWidget);
  });
}
