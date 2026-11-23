// When a shell's navigator leaves with its level, the root's observers hear its
// routes removed, as they hear the pages `go` removes from the root navigator;
// nobody popped them.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/nested_level_fixtures.dart';
import '../support/observer_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/shell_fixtures.dart';
import '../support/tree_fixtures.dart';

/// Hears removals too: `remove user`.
class _RemovalLog extends LogObserver {
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      events.add('remove ${_nameOf(route)}');

  String _nameOf(Route<dynamic> route) => switch (route.settings) {
    Page<Object?>(:final name) => name ?? 'unnamed',
    _ => 'pageless',
  };
}

void main() {
  testWidgets('go that removes a shell tells root observers didRemove, not '
      'didPop', (tester) async {
    final observer = _RemovalLog();
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
        RouteNode<AccountRoute>(
          name: 'account',
          build: (context, account) => const Text('Account'),
        ),
      ],
      users,
      observer,
    );
    final user = ResultProbe(router.push(user1));
    await tester.pumpAndSettle();
    final dialog = ResultProbe(
      showGeneralDialog<void>(
        context: tester.element(find.text('User u1')),
        useRootNavigator: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Text('Dialog'),
      ),
    );
    await tester.pumpAndSettle();
    observer.events.clear();

    await settleAfter(tester, () => router.go(const AccountRoute()));

    expect(observer.events, isNot(contains(startsWith('pop'))));
    expect(observer.events, containsAll(['remove pageless', 'remove user']));
    expect(user.completions, [null]);
    expect(dialog.completions, [null]);
    expect(find.text('Account'), findsOneWidget);
  });

  testWidgets('leaving levels inside levels removes the deepest routes '
      'first, from the top', (tester) async {
    final observer = _RemovalLog();
    final router = await pumpObserved(
      tester,
      nestedShellRoutes(),
      user1,
      observer,
    );
    showGeneralDialog<void>(
      context: tester.element(find.text('User u1')),
      useRootNavigator: false,
      pageBuilder: (context, animation, secondaryAnimation) =>
          const Text('Dialog'),
    ).ignore();
    await tester.pumpAndSettle();
    observer.events.clear();

    await settleAfter(tester, () => router.go(const AccountRoute()));

    // The dialog in the user's shell, then the page of that shell in the
    // users' shell: as a navigator removes what is on top first.
    final dialogRemoved = observer.events.indexOf('remove pageless');
    final shellPageRemoved = observer.events.indexOf('remove unnamed');
    expect(dialogRemoved, isNonNegative);
    expect(dialogRemoved, lessThan(shellPageRemoved));
  });
}
