import 'package:flutter/material.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/scenarios/split_rooms.dart';
import 'package:typed_navigator_example/scenarios/split_routes.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const splitViewListDetailScenario = Scenario(
  title: 'List | detail split',
  summary: 'SplitNode: rooms | room when wide, a stack when narrow.',
  instructions: [
    'Make the window at least 700 wide: "go to the rooms" shows the rooms '
        'and "Pick a room" (the placeholder) side by side.',
    'Tap rooms in the list: go replaces the room column. Tap the counters, '
        'then make the window narrow and wide again: nothing is rebuilt.',
    'In a room, "push room N+1": room N moves left, the list goes '
        'offstage; back brings it back with its counter.',
    '"open the lobby (cover)" covers the whole split; "open the rules '
        '(root)" covers the whole app. Back reveals the columns as they were.',
    '"Navigator.pop this column" closes the column and every one to its '
        'right; the sheet stays in its column when the columns shift.',
    'From the hall, "push room 3 alone" opens a split with only the room.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () => TypedRouter(
    routes: splitRoomsRoutes(
      maximumColumns: (size) => size.width >= 700 ? 2 : 1,
    ),
    initialRoute: const HallRoute(),
    pageFactory: const MaterialPageFactory(),
  ),
);
