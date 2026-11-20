import 'package:flutter/material.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/support/demo_button.dart';
import 'package:typed_navigator_example/support/demo_page.dart';

/// The rooms of the navigator slots scenario: rooms open in a room shell,
/// creating a room goes to the root navigator, members to [roomsSlot].
RouteNode<RoomsRoute> roomsNode(NavigatorSlot roomsSlot) =>
    RouteNode<RoomsRoute>(
      build: (context, rooms) => DemoPage(
        title: 'Rooms',
        actions: [
          DemoButton(
            'Create a room (root slot)',
            onPressed: () =>
                TypedRouter.of(context).push(const CreateRoomRoute()),
          ),
          DemoButton(
            'open room 1',
            onPressed: () => TypedRouter.of(context).go(const RoomRoute(1)),
          ),
        ],
      ),
      children: [
        RouteNode<CreateRoomRoute>(
          parentNavigatorSlot: NavigatorSlot.root,
          build: (context, create) => const DemoPage(
            title: 'Create a room',
            text: 'On the root navigator: no tab bar under this page.',
            actions: [],
          ),
        ).withParent((create) => const RoomsRoute()),
        ShellNode<RoomsRoute>(
          builder: (context, state, navigator) => Column(
            children: [
              Container(
                color: Colors.green.shade100,
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                child: const Text('Room shell'),
              ),
              Expanded(child: navigator),
            ],
          ),
          children: [
            RouteNode<RoomRoute>(
              build: (context, room) => DemoPage(
                title: 'Room ${room.id}',
                actions: [
                  DemoButton(
                    'Members (rooms branch slot)',
                    onPressed: () =>
                        TypedRouter.of(context).push(MembersRoute(room.id)),
                  ),
                ],
              ),
              children: [
                RouteNode<MembersRoute>(
                  parentNavigatorSlot: roomsSlot,
                  build: (context, members) => DemoPage(
                    title: 'Members of room ${members.roomId}',
                    text: 'Above the room shell, inside the Rooms tab.',
                    actions: const [],
                  ),
                ).withParent((members) => RoomRoute(members.roomId)),
              ],
            ).withParent((room) => const RoomsRoute()),
          ],
        ),
      ],
    );

/// Names the rooms tab.
abstract final class RoomsBranch {}

/// Names the about tab.
abstract final class AboutBranch {}

final class RoomsRoute extends TypedRoute<void> {
  const RoomsRoute();

  @override
  List<Object?> get fields => const [];
}

final class RoomRoute extends TypedRoute<void> {
  const RoomRoute(this.id);

  final int id;

  @override
  List<Object?> get fields => [id];
}

final class MembersRoute extends TypedRoute<void> {
  const MembersRoute(this.roomId);

  final int roomId;

  @override
  List<Object?> get fields => [roomId];
}

final class CreateRoomRoute extends TypedRoute<void> {
  const CreateRoomRoute();

  @override
  List<Object?> get fields => const [];
}

final class AboutRoute extends TypedRoute<void> {
  const AboutRoute();

  @override
  List<Object?> get fields => const [];
}
