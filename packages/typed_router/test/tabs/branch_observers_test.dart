// The router's observers hear every visited tabs branch.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import '../support/observer_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/tabs_fixtures.dart';

List<TreeNode<NoParentRoute>> _routes() => [
  StatefulShellNode(
    builder: (context, state, shell) => shell,
    branches: [
      BranchNode<RoomsBranch>(
        initial: const RoomsRoute(),
        children: [
          RouteNode<RoomsRoute>(
            name: 'rooms',
            build: (context, rooms) => const Text('Rooms'),
            children: [
              RouteNode<RoomRoute>(
                name: 'room',
                build: (context, room) => Text('Room ${room.id.value}'),
              ).withParent((room) => const RoomsRoute()),
            ],
          ),
        ],
      ),
      BranchNode<FriendsBranch>(
        initial: friends,
        children: [
          RouteNode<FriendsRoute>(
            name: 'friends',
            build: (context, friends) => const Text('Friends'),
            children: [
              RouteNode<FriendRoute>(
                name: 'friend',
                build: (context, friend) => Text('Friend ${friend.name}'),
              ).withParent((friend) => friends),
            ],
          ),
        ],
      ),
    ],
  ),
];

void main() {
  testWidgets('a root observer hears pushes and pops inside every visited '
      'tabs branch', (tester) async {
    final observer = LogObserver();
    final router = await pumpObserved(
      tester,
      _routes(),
      const RoomsRoute(),
      observer,
    );

    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());
    await settled(tester, () => router.push(ann).ignore());
    await settled(tester, () => shellOf(tester).goBranch<RoomsBranch>());
    await settled(tester, () => router.push(const RoomRoute(RoomId(7))));

    expect(
      observer.events,
      containsAllInOrder(['push friends', 'push friend', 'push room']),
    );
    expect(tester.takeException(), isNull);
  });
}
