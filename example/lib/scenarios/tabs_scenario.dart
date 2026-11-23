import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';
import 'package:typed_router_example/catalogue/scenario.dart';
import 'package:typed_router_example/catalogue/scenario_frame.dart';
import 'package:typed_router_example/scenarios/tab_branches.dart';
import 'package:typed_router_example/scenarios/tabs_navigation_bar.dart';
import 'package:typed_router_example/support/material_page_factory.dart';
import 'package:typed_router_example/support/router_demo.dart';

const tabsScenario = Scenario(
  title: 'Tabs (IndexedStack)',
  summary: 'StatefulShellNode: each tab keeps its own stack.',
  instructions: [
    'Tap the counter on Rooms, push room 1 and 2, switch to Friends and '
        'back: the rooms stack and the count are kept.',
    'Tap the active tab again: it resets to its initial route.',
    'Push a room: the door flies into it. Each tab\'s navigator has a hero '
        'controller of its own, with the app\'s flight path.',
    'On Profile, "go to room 5": go to a route of another branch switches '
        'tabs.',
    'Back pops inside the tab; on a tab\'s first page it goes to Rooms '
        '(PopScope in the builder), on Rooms it closes the app.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () => TypedRouter(
    routes: [
      StatefulShellNode(
        builder: (context, state, shell) => PopScope(
          canPop: shell.currentIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) shell.goBranchAt(0);
          },
          child: Scaffold(
            body: shell,
            bottomNavigationBar: TabsNavigationBar(shell),
          ),
        ),
        branches: tabBranches(),
      ),
    ],
    initialRoute: const RoomsRoute(),
    pageFactory: const MaterialPageFactory(),
  ),
);
