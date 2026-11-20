import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/support/demo_button.dart';
import 'package:typed_navigator_example/support/demo_page.dart';
import 'package:typed_navigator_example/support/material_page_factory.dart';
import 'package:typed_navigator_example/support/router_demo.dart';
import 'package:typed_navigator_example/support/tap_counter.dart';

const typedRoutesScenario = Scenario(
  title: 'Typed routes: go and push',
  summary: 'Routes with fields in a tree; go builds the routes above.',
  instructions: [
    'Help → "go to message 7/3": go builds the routes above it, '
        'State is RoomsRoute() > RoomRoute(7) > MessageRoute(7, 3).',
    'Help → "push message 7/3": push puts only that route on top, '
        'State is HelpRoute() > MessageRoute(7, 3).',
    'In room 7 tap the counter, then "go to room 7 again": an equal route '
        'keeps its page and the count; "go to room 8" builds a new page.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () => TypedRouter(
    routes: _routes,
    initialRoute: const RoomsRoute(),
    pageFactory: const MaterialPageFactory(),
  ),
);

final List<TreeNode<NoParentRoute>> _routes = [
  RouteNode<RoomsRoute>(
    build: (context, rooms) => DemoPage(
      title: 'Rooms',
      actions: [
        for (final id in [7, 8])
          DemoButton(
            'push room $id',
            onPressed: () => TypedRouter.of(context).push(RoomRoute(id)),
          ),
        DemoButton(
          'go to help',
          onPressed: () => TypedRouter.of(context).go(const HelpRoute()),
        ),
      ],
    ),
    children: [
      RouteNode<RoomRoute>(
        build: (context, room) => _RoomPage(room),
        children: [
          RouteNode<MessageRoute>(
            build: (context, message) => DemoPage(
              title: 'Message ${message.messageId}',
              text: 'In room ${message.roomId}.',
              actions: const [],
            ),
          ).withParent((message) => RoomRoute(message.roomId)),
        ],
      ).withParent((room) => const RoomsRoute()),
    ],
  ),
  RouteNode<HelpRoute>(build: (context, help) => const _HelpPage()),
];

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

final class MessageRoute extends TypedRoute<void> {
  const MessageRoute(this.roomId, this.messageId);

  final int roomId;
  final int messageId;

  @override
  List<Object?> get fields => [roomId, messageId];
}

final class HelpRoute extends TypedRoute<void> {
  const HelpRoute();

  @override
  List<Object?> get fields => const [];
}

final class _RoomPage extends StatelessWidget {
  const _RoomPage(this.room);

  final RoomRoute room;

  @override
  Widget build(BuildContext context) {
    final router = TypedRouter.of(context);
    return DemoPage(
      title: 'Room ${room.id}',
      actions: [
        const TapCounter(),
        DemoButton(
          'go to room ${room.id} again',
          onPressed: () => router.go(RoomRoute(room.id)),
        ),
        DemoButton(
          'go to room ${room.id + 1}',
          onPressed: () => router.go(RoomRoute(room.id + 1)),
        ),
      ],
    );
  }
}

final class _HelpPage extends StatelessWidget {
  const _HelpPage();

  @override
  Widget build(BuildContext context) {
    final router = TypedRouter.of(context);
    return DemoPage(
      title: 'Help (outside the rooms tree)',
      actions: [
        DemoButton(
          'go to message 7/3',
          onPressed: () => router.go(const MessageRoute(7, 3)),
        ),
        DemoButton(
          'push message 7/3',
          onPressed: () => router.push(const MessageRoute(7, 3)),
        ),
        DemoButton(
          'go to rooms',
          onPressed: () => router.go(const RoomsRoute()),
        ),
      ],
    );
  }
}
