// A shell as a middle column with a stack of its own: its back button works,
// the gesture stays out, a column to its left asks its top page.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/testing.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/column_back_fixtures.dart';
import '../support/split_fixtures.dart';

Widget _page(String title) => Scaffold(appBar: AppBar(title: Text(title)));

/// Rooms | room 1 | a shell around the lobby and [player] | the rules, in
/// [columns] columns; player eve refuses back. Pops go to [attempts].
List<TreeNode<NoParentRoute>> _routes(
  int columns,
  PlayerRoute player,
  List<bool> attempts,
) {
  final splitSlot = NavigatorSlot();
  return [
    SplitNode<NoParentRoute>(
      maximumColumns: (size) => columns,
      navigatorSlot: splitSlot,
      children: [
        RouteNode<RoomsRoute>(
          build: (context, rooms) => _page('Rooms'),
          children: [
            RouteNode<RoomRoute>(
              build: (context, room) => _page('Room ${room.id.value}'),
              children: [
                ShellNode<RoomRoute>(
                  builder: (context, state, navigator) => navigator,
                  children: [
                    RouteNode<LobbyRoute>(
                      build: (context, lobby) => _page('Lobby'),
                      children: [
                        RouteNode<PlayerRoute>(
                          build: (context, player) => PopScope<Object?>(
                            canPop: player.name != 'eve',
                            onPopInvokedWithResult: (didPop, result) =>
                                attempts.add(didPop),
                            child: _page('Player ${player.name}'),
                          ),
                          children: [
                            RouteNode<RulesRoute>(
                              build: (context, rules) => _page('Rules'),
                              parentNavigatorSlot: splitSlot,
                            ).withParent((rules) => player),
                          ],
                        ).withParent(
                          (player) => LobbyRoute(player.roomId),
                        ),
                      ],
                    ).withParent(
                      (lobby) => RoomRoute(RoomId(lobby.roomId)),
                    ),
                  ],
                ),
              ],
            ).withParent((room) => const RoomsRoute()),
          ],
        ),
      ],
    ),
  ];
}

const _ann = PlayerRoute(1, 'ann');

/// Three columns with player ann on top of the shell and the rules last.
Future<TypedRouter> _pumpAnn(WidgetTester tester, List<bool> attempts) =>
    pumpColumns(tester, _routes(3, _ann, attempts), const RulesRoute());
const _all =
    '[RoomsRoute() > RoomRoute(RoomId(1)) > [LobbyRoute(1) > '
    'PlayerRoute(1, ann)] > RulesRoute()]';

void main() {
  testWidgets('the back button of the top page inside a shell in a middle '
      'column closes that page, and its PopScope hears it once', (
    tester,
  ) async {
    final attempts = <bool>[];
    final router = await _pumpAnn(tester, attempts);
    expect(router.state.toString(), _all);

    await tester.tap(backButtonOf('Player ann'));
    await tester.pumpAndSettle();

    expect(
      router.state.toString(),
      '[RoomsRoute() > RoomRoute(RoomId(1)) > [LobbyRoute(1)] > '
      'RulesRoute()]',
    );
    expect(backButtonOf('Lobby'), findsNothing);
    expect(attempts, [true]);
  });

  testWidgets('predictive back skips the pages inside a middle shell column', (
    tester,
  ) async {
    final router = await _pumpAnn(tester, []);

    await tester.predictiveBack();

    expect(
      router.state.toString(),
      '[RoomsRoute() > RoomRoute(RoomId(1)) > [LobbyRoute(1) > '
      'PlayerRoute(1, ann)]]',
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('the iOS swipe skips the pages inside a middle shell column', (
    tester,
  ) async {
    final router = await _pumpAnn(tester, []);
    final edge = tester.getTopLeft(find.text('Player ann')).dx;

    await tester.dragFrom(Offset(edge - 10, 500), const Offset(300, 0));
    await tester.pumpAndSettle();

    expect(router.state.toString(), _all);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('a refusing top page inside a shell column to the right keeps '
      'the column on the left open', (tester) async {
    final attempts = <bool>[];
    const eve = PlayerRoute(1, 'eve');
    final router = await pumpColumns(
      tester,
      _routes(4, eve, attempts),
      const RulesRoute(),
    );
    final before = router.state.toString();

    await tester.tap(backButtonOf('Room 1'));
    await tester.pumpAndSettle();

    expect(attempts, [false]);
    expect(router.state.toString(), before);
  });
}
