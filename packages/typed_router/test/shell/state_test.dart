// The state across shells, and a shell without children.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import '../support/app_fixtures.dart';
import '../support/shell_fixtures.dart';
import '../support/tree_fixtures.dart';

void main() {
  testWidgets('toString marks the shell navigator and routes skip the '
      'shell', (tester) async {
    final router = await pumpShellApp(tester, user1);
    await settleAfter(tester, () => router.push(account).ignore());

    final state = router.state;

    expect(
      state.toString(),
      '[UsersRoute() > UserRoute(u1)] > AccountRoute()',
    );
    expect(state.routes, const [users, user1, account]);
    expect(state.top, account);
    expect(state.find<UserRoute>(), user1);
    expect(state.contains<UsersRoute>(), isTrue);
  });

  test('a shell without children fails when the router is built', () {
    expect(
      () => TypedRouter(
        routes: [
          ShellNode<NoParentRoute>(
            builder: (context, state, navigator) => navigator,
            children: const [],
          ),
        ],
        initialRoute: account,
        pageFactory: const TestPageFactory(),
      ),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'A ShellNode has no children. Give it at least one node.',
        ),
      ),
    );
  });
}
