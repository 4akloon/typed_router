import 'package:flutter/material.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/scenarios/slot_routes.dart';
import 'package:typed_navigator_example/support/demo_page.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const navigatorSlotsScenario = Scenario(
  title: 'Navigator slots',
  summary: 'parentNavigatorSlot: a page over the tabs, or above a shell.',
  instructions: [
    '"Create a room" is placed on NavigatorSlot.root: it covers the tabs '
        'and their bar; State shows it after the braces.',
    'Open room 1: it shows in the green room shell, inside the Rooms tab.',
    'In the room, "Members" is placed in the Rooms branch\'s slot: it '
        'covers the room shell but not the tab bar.',
    'Back closes each in turn: members, the room, the page on the root.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () => TypedRouter(
    routes: _routes(),
    initialRoute: const RoomsRoute(),
    pageFactory: const MaterialPageFactory(),
  ),
);

/// A new slot per router: the rooms branch's navigator.
List<TreeNode<NoParentRoute>> _routes() {
  final roomsSlot = NavigatorSlot();
  return [
    StatefulShellNode(
      builder: (context, state, shell) => Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: shell.goBranchAt,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.meeting_room),
              label: 'Rooms',
            ),
            NavigationDestination(icon: Icon(Icons.info), label: 'About'),
          ],
        ),
      ),
      branches: [
        BranchNode<RoomsBranch>(
          initial: const RoomsRoute(),
          navigatorSlot: roomsSlot,
          children: [roomsNode(roomsSlot)],
        ),
        BranchNode<AboutBranch>(
          initial: const AboutRoute(),
          children: [
            RouteNode<AboutRoute>(
              build: (context, about) => const DemoPage(
                title: 'About',
                text: 'The second tab.',
                actions: [],
              ),
            ),
          ],
        ),
      ],
    ),
  ];
}
