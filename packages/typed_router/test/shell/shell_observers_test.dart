// The router's observers hear the navigator of a shell, as go_router's do.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import '../support/observer_fixtures.dart';
import '../support/shell_fixtures.dart';
import '../support/tree_fixtures.dart';

void main() {
  testWidgets("a root observer hears pushes and pops inside a shell's "
      'navigator', (tester) async {
    final observer = LogObserver();
    final router = await pumpObserved(
      tester,
      [
        ShellNode<NoParentRoute>(
          builder: (context, state, navigator) => navigator,
          children: [
            RouteNode<UsersRoute>(
              name: 'users',
              build: (context, users) => const Text('Users'),
              children: [
                RouteNode<UserRoute>(
                  name: 'user',
                  build: (context, user) => Text('User ${user.userId}'),
                ).withParent((user) => const UsersRoute()),
              ],
            ),
          ],
        ),
      ],
      users,
      observer,
    );

    await settleAfter(tester, () => router.push(user1).ignore());
    await settleAfter(tester, () => router.pop(null));

    expect(observer.events.where((event) => event.contains('user')), [
      'push users',
      'push user',
      'pop user',
    ]);
  });
}
