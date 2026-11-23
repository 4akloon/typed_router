// The system back button goes to the deepest current navigator first, as
// go_router's does: a page inside a level closes without asking the level's
// frame, and a drawer (a local history entry) inside closes first.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_test/typed_navigator_test.dart';

import '../support/app_fixtures.dart';
import '../support/shell_fixtures.dart';
import '../support/tree_fixtures.dart';

void main() {
  testWidgets('system back pops inside a shell without asking the PopScope '
      'of its frame', (tester) async {
    final refusals = <bool>[];
    final router = TypedRouter(
      routes: [
        ShellNode<NoParentRoute>(
          builder: (context, state, navigator) => PopScope<Object?>(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) => refusals.add(didPop),
            child: navigator,
          ),
          children: [
            RouteNode<UsersRoute>(
              build: (context, users) => const Text('Users'),
              children: [
                RouteNode<UserRoute>(
                  build: (context, user) => Text('User ${user.userId}'),
                ).withParent((user) => const UsersRoute()),
              ],
            ),
          ],
        ),
      ],
      initialRoute: const UserRoute('u1'),
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);

    await tester.systemBack();
    await tester.pumpAndSettle();

    expect(router.state.routes, const [UsersRoute()]);
    expect(find.text('Users'), findsOneWidget);
    expect(refusals, isEmpty);
  });

  testWidgets('system back closes a local history entry (a drawer) of a '
      'shell page when the shell is the only root page', (tester) async {
    final router = await pumpShellApp(tester, users);
    var removed = false;
    ModalRoute.of(
      tester.element(find.text('Users')),
    )?.addLocalHistoryEntry(LocalHistoryEntry(onRemove: () => removed = true));
    await tester.pumpAndSettle();

    await tester.systemBack();
    await tester.pumpAndSettle();

    expect(removed, isTrue);
    expect(router.state.routes, const [users]);
  });

  testWidgets('system back closes a local history entry of a shell page '
      'above another root page', (tester) async {
    final router = await pumpShellApp(tester, account);
    router.push(users).ignore();
    await tester.pumpAndSettle();
    var removed = false;
    ModalRoute.of(
      tester.element(find.text('Users')),
    )?.addLocalHistoryEntry(LocalHistoryEntry(onRemove: () => removed = true));
    await tester.pumpAndSettle();

    await tester.systemBack();
    await tester.pumpAndSettle();

    expect(removed, isTrue);
    expect(router.state.routes, const [account, users]);
    expect(find.text('Users'), findsOneWidget);
  });
}
