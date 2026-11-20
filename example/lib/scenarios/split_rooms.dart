import 'package:flutter/material.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/scenarios/split_routes.dart';
import 'package:typed_navigator_example/support/demo_button.dart';
import 'package:typed_navigator_example/support/demo_page.dart';
import 'package:typed_navigator_example/support/tap_counter.dart';

/// The rooms app on a split, shared by the split demos: the hall outside,
/// rooms with a placeholder, a room, its lobby over the split, the rules
/// over the app. [builder] lays the columns out; `null` for the default.
List<TreeNode<NoParentRoute>> splitRoomsRoutes({
  required int Function(Size size) maximumColumns,
  Widget Function(BuildContext context, NavigationState state, SplitView split)?
  builder,
}) => [
  RouteNode<HallRoute>(
    build: (context, hall) => DemoPage(
      title: 'Hall',
      text: 'Outside the split.',
      actions: [
        DemoButton(
          'go to the rooms',
          onPressed: () => TypedRouter.of(context).go(const RoomsRoute()),
        ),
        DemoButton(
          'push room 3 alone',
          onPressed: () => TypedRouter.of(context).push(const RoomRoute(3)),
        ),
      ],
    ),
  ),
  SplitNode<NoParentRoute>(
    maximumColumns: maximumColumns,
    builder: builder,
    children: [
      RouteNode<RoomsRoute>(
        build: (context, rooms) => const _RoomsList(),
        placeholder: (context, rooms) =>
            const Scaffold(body: Center(child: Text('Pick a room'))),
        children: [
          RouteNode<RoomRoute>(
            build: _roomPage,
            children: [
              RouteNode<LobbyRoute>(
                build: (context, lobby) => DemoPage(
                  title: 'Lobby of room ${lobby.number}',
                  text: 'SplitPresentation.cover: over the whole split.',
                  actions: const [TapCounter()],
                ),
                splitPresentation: SplitPresentation.cover,
              ).withParent((lobby) => RoomRoute(lobby.number)),
            ],
          ).withParent((room) => const RoomsRoute()),
          RouteNode<RulesRoute>(
            build: (context, rules) => const DemoPage(
              title: 'Rules',
              text: 'NavigatorSlot.root: over the whole app.',
              actions: [],
            ),
            parentNavigatorSlot: NavigatorSlot.root,
          ).withParent((rules) => const RoomsRoute()),
        ],
      ),
    ],
  ),
];

Widget _roomPage(BuildContext context, RoomRoute room) {
  final router = TypedRouter.of(context);
  return DemoPage(
    title: 'Room ${room.number}',
    actions: [
      const TapCounter(),
      DemoButton(
        'push room ${room.number + 1}',
        onPressed: () => router.push(RoomRoute(room.number + 1)),
      ),
      DemoButton(
        'open the lobby (cover)',
        onPressed: () => router.push(LobbyRoute(room.number)),
      ),
      DemoButton(
        'open the rules (root)',
        onPressed: () => router.push(const RulesRoute()),
      ),
      DemoButton(
        'open a sheet in this column',
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          useRootNavigator: false,
          builder: (context) => const SizedBox(
            height: 160,
            child: Center(child: Text('A pageless route of this column')),
          ),
        ),
      ),
      DemoButton(
        'Navigator.pop this column',
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );
}

/// The rooms list; a tap selects a room with `go`, so the next column is
/// replaced, not stacked. The room open beside it is highlighted.
final class _RoomsList extends StatelessWidget {
  const _RoomsList();

  @override
  Widget build(BuildContext context) {
    final router = TypedRouter.of(context);
    // NavigationState.of rebuilds this const page on navigation.
    final selected = NavigationState.of(context).find<RoomRoute>();
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms')),
      body: ListView(
        children: [
          const Padding(padding: EdgeInsets.all(8), child: TapCounter()),
          for (final number in [1, 2, 3, 4, 5])
            ListTile(
              title: Text('Room $number'),
              selected: selected?.number == number,
              onTap: () => router.go(RoomRoute(number)),
            ),
        ],
      ),
    );
  }
}
