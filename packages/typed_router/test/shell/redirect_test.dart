// A shell redirect guards its subtree before the nodes below, once per
// chain.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import '../support/app_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/shell_fixtures.dart';
import '../support/tree_fixtures.dart';

void main() {
  testWidgets('a shell redirect guards its subtree before the nodes below', (
    tester,
  ) async {
    var isGuest = true;
    final calls = <String>[];
    final session = ValueNotifier(0);
    addTearDown(session.dispose);
    final router = TypedRouter(
      routes: [
        ShellNode<NoParentRoute>(
          builder: (context, state, navigator) => navigator,
          redirect: (context, target) {
            calls.add('shell: ${target.top}');
            return isGuest ? account : null;
          },
          children: [
            RouteNode<UsersRoute>(
              build: (context, users) => const Text('Users'),
              redirect: (context, users, target) {
                calls.add('Users node: ${target.top}');
                return null;
              },
            ),
          ],
        ),
        RouteNode<AccountRoute>(build: (context, account) => const Text('')),
      ],
      initialRoute: account,
      pageFactory: const TestPageFactory(),
      refreshListenable: session,
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);

    router.push(users).ignore();
    expect(router.state.toString(), 'AccountRoute() > AccountRoute()');
    expect(calls, ['shell: UsersRoute()']);

    isGuest = false;
    calls.clear();
    router.go(users);
    expect(router.state.toString(), '[UsersRoute()]');
    expect(calls, ['shell: UsersRoute()', 'Users node: UsersRoute()']);

    isGuest = true;
    session.value++;
    expect(router.state.toString(), 'AccountRoute()');
    await tester.pumpAndSettle();
    expect(find.text(''), findsOneWidget);
    expect(find.text('Users', skipOffstage: false), findsNothing);
  });

  testWidgets('a shell redirect runs once for a chain of routes inside it', (
    tester,
  ) async {
    final calls = <String>[];
    final router = TypedRouter(
      routes: [
        ShellNode<NoParentRoute>(
          builder: (context, state, navigator) => navigator,
          redirect: (context, target) {
            calls.add('shell');
            return null;
          },
          children: [
            RouteNode<UsersRoute>(
              build: (context, users) => const Text('Users'),
              children: [
                RouteNode<UserRoute>(
                  build: (context, user) => Text('User ${user.userId}'),
                ).withParent((user) => users),
              ],
            ),
          ],
        ),
        RouteNode<AccountRoute>(build: (context, account) => const Text('')),
      ],
      initialRoute: account,
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);
    calls.clear();

    router.go(user1);
    await tester.pumpAndSettle();

    expect(calls, ['shell']);
    expect(find.text('User u1'), findsOneWidget);
  });
}
