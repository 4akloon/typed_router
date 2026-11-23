import 'package:typed_router/typed_router.dart';
import 'package:typed_router_example/support/demo_button.dart';
import 'package:typed_router_example/support/demo_page.dart';
import 'package:typed_router_example/support/room_badge.dart';
import 'package:typed_router_example/support/tap_counter.dart';

/// The branches of the two tabs scenarios: rooms, friends and a profile,
/// each with its own navigator and kept stack.
List<BranchNode<Object?>> tabBranches() => [
  BranchNode<RoomsBranch>(
    initial: const RoomsRoute(),
    children: [
      RouteNode<RoomsRoute>(
        build: (context, rooms) => DemoPage(
          title: 'Rooms',
          actions: [
            const RoomBadge(size: 32),
            const TapCounter(),
            DemoButton(
              'push room 1',
              onPressed: () => TypedRouter.of(context).push(const RoomRoute(1)),
            ),
          ],
        ),
        children: [
          RouteNode<RoomRoute>(
            build: (context, room) => DemoPage(
              title: 'Room ${room.id}',
              actions: [
                const RoomBadge(size: 96),
                DemoButton(
                  'push room ${room.id + 1}',
                  onPressed: () =>
                      TypedRouter.of(context).push(RoomRoute(room.id + 1)),
                ),
              ],
            ),
          ).withParent((room) => const RoomsRoute()),
        ],
      ),
    ],
  ),
  BranchNode<FriendsBranch>(
    initial: const FriendsRoute(),
    children: [
      RouteNode<FriendsRoute>(
        build: (context, friends) => const DemoPage(
          title: 'Friends',
          text: 'Built on the first visit to this tab.',
          actions: [TapCounter()],
        ),
      ),
    ],
  ),
  BranchNode<ProfileBranch>(
    initial: const ProfileRoute(),
    children: [
      RouteNode<ProfileRoute>(
        build: (context, profile) => DemoPage(
          title: 'Profile',
          actions: [
            DemoButton(
              'go to room 5 (another tab)',
              onPressed: () => TypedRouter.of(context).go(const RoomRoute(5)),
            ),
          ],
        ),
      ),
    ],
  ),
];

/// Names the rooms tab.
abstract class RoomsBranch {}

/// Names the friends tab.
abstract class FriendsBranch {}

/// Names the profile tab.
abstract class ProfileBranch {}

class RoomsRoute extends TypedRoute<void> {
  const RoomsRoute();

  @override
  List<Object?> get fields => const [];
}

class RoomRoute extends TypedRoute<void> {
  const RoomRoute(this.id);

  final int id;

  @override
  List<Object?> get fields => [id];
}

class FriendsRoute extends TypedRoute<void> {
  const FriendsRoute();

  @override
  List<Object?> get fields => const [];
}

class ProfileRoute extends TypedRoute<void> {
  const ProfileRoute();

  @override
  List<Object?> get fields => const [];
}
