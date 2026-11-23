// Entries know their shells; the state shows navigator boundaries in toString
// and keeps routes flat.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/route_fixtures.dart';

ShellNode<NoParentRoute> _shellNode() => ShellNode<NoParentRoute>(
  builder: (context, state, navigator) => navigator,
  children: [RouteNode<RoomsRoute>(build: (context, rooms) => const Text(''))],
);

void main() {
  const rooms = RoomsRoute();
  const room7 = RoomRoute(RoomId(7));
  const room8 = RoomRoute(RoomId(8));
  const account = AccountRoute();

  test('routes are flat across shells', () {
    final shell = ShellEntry(_shellNode());
    final state = TypedRouterState.fromEntries([
      NavigationEntry(rooms, levels: [shell]),
      NavigationEntry(room7, levels: [shell]),
      NavigationEntry(account),
    ]);

    expect(state.routes, const [rooms, room7, account]);
    expect(state.top, account);
  });

  test('toString marks each shell navigator with brackets', () {
    final outer = ShellEntry(_shellNode());
    final inner = ShellEntry(_shellNode());
    final state = TypedRouterState.fromEntries([
      NavigationEntry(rooms, levels: [outer]),
      NavigationEntry(room7, levels: [outer, inner]),
      NavigationEntry(room8, levels: [outer, inner]),
      NavigationEntry(account),
    ]);

    expect(
      state.toString(),
      '[RoomsRoute() > [RoomRoute(RoomId(7)) > RoomRoute(RoomId(8))]] > '
      'AccountRoute()',
    );
  });

  test('two instances of one shell node are two navigators', () {
    final node = _shellNode();
    final first = ShellEntry(node);
    final second = ShellEntry(node);
    final state = TypedRouterState.fromEntries([
      NavigationEntry(rooms, levels: [first]),
      NavigationEntry(room7, levels: [second]),
    ]);

    expect(
      state.toString(),
      '[RoomsRoute()] > [RoomRoute(RoomId(7))]',
    );
  });
}
