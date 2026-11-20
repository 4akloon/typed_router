// Back from a middle column asks the state's top page even when it stands
// inside a shell in the deepest column.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/column_back_fixtures.dart';
import '../support/split_fixtures.dart';

/// Rooms | a room | a shell around the player, who refuses back and adds
/// each attempt to [attempts].
List<TreeNode<NoParentRoute>> _shellDeepest(List<bool> attempts) => [
  SplitNode<NoParentRoute>(
    maximumColumns: (size) => 3,
    children: [
      RouteNode<RoomsRoute>(
        build: (context, rooms) => const Text('Rooms'),
        children: [
          RouteNode<RoomRoute>(
            build: (context, room) => Scaffold(
              appBar: AppBar(title: Text('Room ${room.id.value}')),
            ),
            children: [
              ShellNode<RoomRoute>(
                builder: (context, state, navigator) => navigator,
                children: [
                  RouteNode<PlayerRoute>(
                    build: (context, player) => PopScope<Object?>(
                      canPop: false,
                      onPopInvokedWithResult: (didPop, result) =>
                          attempts.add(didPop),
                      child: Text('Player ${player.name}'),
                    ),
                  ).withParent((player) => RoomRoute(RoomId(player.roomId))),
                ],
              ),
            ],
          ).withParent((room) => const RoomsRoute()),
        ],
      ),
    ],
  ),
];

void main() {
  testWidgets('a refusing top page inside a shell in the deepest column '
      'keeps a middle column open', (tester) async {
    final attempts = <bool>[];
    final router = await pumpColumns(
      tester,
      _shellDeepest(attempts),
      const PlayerRoute(1, 'eve'),
    );
    final before = router.state.toString();

    await tester.tap(backButtonOf('Room 1'));
    await tester.pumpAndSettle();

    expect(attempts, [false]);
    expect(router.state.toString(), before);
  });
}
