// The router finds the navigator of a slot on the active path, for code outside
// the shell's widgets.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import '../support/app_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/shell_fixtures.dart';
import '../support/slots_fixtures.dart';
import '../support/tabs_fixtures.dart';
import '../support/tree_fixtures.dart';

void main() {
  testWidgets('navigatorOf finds the navigator of a slot on screen', (
    tester,
  ) async {
    final router = await pumpSlotsApp(tester);

    expect(
      router.navigatorOf(roomsSlot),
      same(Navigator.of(tester.element(find.text('Rooms')))),
    );
    expect(router.navigatorOf(NavigatorSlot.root), same(router.navigator));
    expect(router.navigatorOf(NavigatorSlot()), isNull);

    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());
    expect(find.text('Friends'), findsOneWidget);
    expect(router.navigatorOf(roomsSlot), isNull);
  });

  test('navigatorOf is null while the router is not shown', () {
    final router = TypedRouter(
      routes: slotRoutes(),
      initialRoute: const RoomsRoute(),
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);

    expect(router.navigatorOf(roomsSlot), isNull);
    expect(router.navigatorOf(NavigatorSlot.root), isNull);
  });

  testWidgets("navigatorOf finds a shell's navigator, the instance nearest "
      'the top', (tester) async {
    final usersSlot = NavigatorSlot();
    final router = TypedRouter(
      routes: [
        ShellNode<NoParentRoute>(
          navigatorSlot: usersSlot,
          builder: (context, state, navigator) => navigator,
          children: [
            RouteNode<UsersRoute>(
              build: (context, users) => const Text('Users'),
            ),
          ],
        ),
        RouteNode<AccountRoute>(
          build: (context, account) => const Text('Account'),
        ),
      ],
      initialRoute: users,
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);
    final first = router.navigatorOf(usersSlot);
    await settleAfter(tester, () => router.push(account).ignore());
    await settleAfter(tester, () => router.push(users).ignore());

    expect(
      router.state.toString(),
      '[UsersRoute()] > AccountRoute() > [UsersRoute()]',
    );
    expect(
      router.navigatorOf(usersSlot),
      same(Navigator.of(tester.element(find.text('Users')))),
    );
    expect(router.navigatorOf(usersSlot), isNot(same(first)));
  });
}
