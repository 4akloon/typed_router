// Routes shown in another navigator than the nearest one.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_test/typed_navigator_test.dart';

import '../support/app_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/slots_fixtures.dart';
import '../support/tabs_fixtures.dart';
import '../support/tree_fixtures.dart';

const _onRoot = '{*RoomsBranch: [RoomsRoute()]} > CreateRoomRoute()';

int _rootPages(TypedRouter router) =>
    router.navigator?.widget.pages.length ?? 0;

void main() {
  testWidgets('go to a route placed on the root shows it above the tabs', (
    tester,
  ) async {
    final router = await pumpSlotsApp(tester);

    await settled(tester, () => router.go(const CreateRoomRoute()));

    expect(router.state.toString(), _onRoot);
    expect(_rootPages(router), 2);
    expect(find.text('Create room'), findsOneWidget);
  });

  testWidgets('push of a route placed on the root shows it above the tabs', (
    tester,
  ) async {
    final router = await pumpSlotsApp(tester);

    await settled(tester, () => router.push(const CreateRoomRoute()).ignore());

    expect(router.state.toString(), _onRoot);
    expect(_rootPages(router), 2);
  });

  testWidgets('children of a placed route stay in its navigator', (
    tester,
  ) async {
    final router = await pumpSlotsApp(tester);

    await settled(tester, () => router.go(const EditNoteRoute()));

    expect(router.state.toString(), '$_onRoot > EditNoteRoute()');
    expect(_rootPages(router), 3);
  });

  testWidgets('a route placed in a branch shows above the shell inside it', (
    tester,
  ) async {
    final router = await pumpSlotsApp(tester);

    await settled(tester, () => router.go(const AccountRoute()));

    expect(
      router.state.toString(),
      '{*RoomsBranch: [RoomsRoute() > [RoomRoute(RoomId(1))] > '
      'AccountRoute()]}',
    );
  });

  testWidgets('a route placed in an outer shell shows above the inner '
      'shell', (tester) async {
    final listDetail = NavigatorSlot();
    final router = TypedRouter(
      routes: [
        ShellNode<NoParentRoute>(
          builder: (context, state, navigator) => navigator,
          navigatorSlot: listDetail,
          children: [
            RouteNode<UsersRoute>(
              build: (context, users) => const Text('Users'),
              children: [
                ShellNode<UsersRoute>(
                  builder: (context, state, navigator) => navigator,
                  children: [
                    RouteNode<UserRoute>(
                      build: (context, user) => Text('User ${user.userId}'),
                      children: [
                        RouteNode<UserGamesRoute>(
                          build: (context, games) => const Text('Games'),
                          parentNavigatorSlot: listDetail,
                        ).withParent((games) => UserRoute(games.userId)),
                      ],
                    ).withParent((user) => const UsersRoute()),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
      initialRoute: const UsersRoute(),
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);

    await settled(tester, () => router.go(const UserGamesRoute('u1')));

    expect(
      router.state.toString(),
      '[UsersRoute() > [UserRoute(u1)] > UserGamesRoute(u1)]',
    );
    expect(find.text('Games'), findsOneWidget);
  });

  testWidgets('back removes the placed route first', (tester) async {
    final router = await pumpSlotsApp(tester);
    await settled(tester, () => router.go(const EditNoteRoute()));

    await tester.systemBack();
    expect(router.state.toString(), _onRoot);

    await tester.systemBack();
    expect(router.state.toString(), '{*RoomsBranch: [RoomsRoute()]}');
    expect(find.text('Rooms'), findsOneWidget);
  });

  testWidgets('tab redirects guard routes placed above the tabs', (
    tester,
  ) async {
    final calls = <String>[];
    var isBlocked = false;
    final router = await pumpSlotsApp(
      tester,
      calls: calls,
      isPlacedBlocked: () => isBlocked,
    );
    isBlocked = true;
    calls.clear();

    await settled(tester, () => router.push(const CreateRoomRoute()).ignore());
    expect(calls.first, 'tabs: CreateRoomRoute()');
    expect(router.state.top, isNot(isA<CreateRoomRoute>()));

    calls.clear();
    const profile = ProfileRoute('u1', 'games');
    await settled(tester, () => router.push(profile).ignore());
    expect(calls.first, 'tabs: ProfileRoute(u1, games)');
    expect(router.state.top, isNot(profile));
  });
}
