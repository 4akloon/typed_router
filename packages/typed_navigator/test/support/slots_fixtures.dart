// Routes placed in other navigators, as a create-room sheet over the tabs:
// rooms tabs whose branch has a slot, a create-room route on the root with a
// child, a shell inside the branch whose child shows in the branch's navigator.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import 'app_fixtures.dart';
import 'route_fixtures.dart';
import 'tabs_fixtures.dart';

final roomsSlot = NavigatorSlot();

/// The app's tree; every redirect call of the tabs is logged to `calls`.
List<TreeNode<NoParentRoute>> slotRoutes({
  List<String>? calls,
  bool Function()? isPlacedBlocked,
}) => [
  StatefulShellNode(
    builder: (context, state, shell) => shell,
    redirect: (context, target) {
      calls?.add('tabs: ${target.top}');
      final isBlocked = isPlacedBlocked?.call() ?? false;
      final isPlaced =
          target.top is CreateRoomRoute || target.top is ProfileRoute;
      return isBlocked && isPlaced ? friends : null;
    },
    branches: [
      BranchNode<RoomsBranch>(
        initial: const RoomsRoute(),
        navigatorSlot: roomsSlot,
        children: [
          // No ancestor in the tabs: only its nesting in the tree tells
          // that the tabs guard it.
          RouteNode<ProfileRoute>(
            build: (context, profile) => const Text('Profile'),
            parentNavigatorSlot: NavigatorSlot.root,
          ),
          RouteNode<RoomsRoute>(
            build: (context, rooms) => const Text('Rooms'),
            children: [
              RouteNode<CreateRoomRoute>(
                build: (context, create) => const Text('Create room'),
                parentNavigatorSlot: NavigatorSlot.root,
                children: [
                  RouteNode<EditNoteRoute>(
                    build: (context, note) => const Text('Edit note'),
                  ).withParent((note) => const CreateRoomRoute()),
                ],
              ).withParent((create) => const RoomsRoute()),
              ShellNode<RoomsRoute>(
                builder: (context, state, navigator) => navigator,
                children: [
                  RouteNode<RoomRoute>(
                    build: (context, room) => Text('Room ${room.id.value}'),
                    children: [
                      RouteNode<AccountRoute>(
                        build: (context, account) => const Text('Account'),
                        parentNavigatorSlot: roomsSlot,
                      ).withParent((account) => const RoomRoute(RoomId(1))),
                    ],
                  ).withParent((room) => const RoomsRoute()),
                ],
              ),
            ],
          ),
        ],
      ),
      BranchNode<FriendsBranch>(
        initial: friends,
        children: [
          RouteNode<FriendsRoute>(
            build: (context, friends) => const Text('Friends'),
          ),
        ],
      ),
    ],
  ),
];

/// A router over [slotRoutes] at the rooms, shown in a WidgetsApp;
/// disposed when the test ends.
Future<TypedRouter> pumpSlotsApp(
  WidgetTester tester, {
  List<String>? calls,
  bool Function()? isPlacedBlocked,
}) async {
  final router = TypedRouter(
    routes: slotRoutes(calls: calls, isPlacedBlocked: isPlacedBlocked),
    initialRoute: const RoomsRoute(),
    pageFactory: const TestPageFactory(),
  );
  addTearDown(router.dispose);
  await pumpWidgetsRouter(tester, router);
  return router;
}
