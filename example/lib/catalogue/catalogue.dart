import 'package:typed_navigator_example/catalogue/scenario_section.dart';
import 'package:typed_navigator_example/catalogue/split_view_scenarios.dart';
import 'package:typed_navigator_example/scenarios/back_button_scenario.dart';
import 'package:typed_navigator_example/scenarios/cupertino_scenario.dart';
import 'package:typed_navigator_example/scenarios/exit_confirmation_scenario.dart';
import 'package:typed_navigator_example/scenarios/initial_route_scenario.dart';
import 'package:typed_navigator_example/scenarios/navigator_slots_scenario.dart';
import 'package:typed_navigator_example/scenarios/page_factories_scenario.dart';
import 'package:typed_navigator_example/scenarios/predictive_back_scenario.dart';
import 'package:typed_navigator_example/scenarios/redirect_error_scenario.dart';
import 'package:typed_navigator_example/scenarios/shell_scenario.dart';
import 'package:typed_navigator_example/scenarios/sign_in_guard_scenario.dart';
import 'package:typed_navigator_example/scenarios/stack_operations_scenario.dart';
import 'package:typed_navigator_example/scenarios/tabs_page_view_scenario.dart';
import 'package:typed_navigator_example/scenarios/tabs_scenario.dart';
import 'package:typed_navigator_example/scenarios/typed_results_scenario.dart';
import 'package:typed_navigator_example/scenarios/typed_routes_scenario.dart';

/// Every scenario of the example, by the version that built it.
const List<ScenarioSection> catalogue = [
  ScenarioSection(
    title: '0.1 Routes and stack operations',
    scenarios: [
      typedRoutesScenario,
      typedResultsScenario,
      stackOperationsScenario,
      initialRouteScenario,
    ],
  ),
  ScenarioSection(
    title: '0.1 / 0.3 Back',
    scenarios: [
      backButtonScenario,
      exitConfirmationScenario,
      predictiveBackScenario,
    ],
  ),
  ScenarioSection(
    title: '0.2 Redirects',
    scenarios: [signInGuardScenario, redirectErrorScenario],
  ),
  ScenarioSection(
    title: '0.3 Shells, tabs and slots',
    scenarios: [
      shellScenario,
      tabsScenario,
      tabsPageViewScenario,
      navigatorSlotsScenario,
    ],
  ),
  ScenarioSection(
    title: 'Page factories',
    scenarios: [pageFactoriesScenario, cupertinoScenario],
  ),
  ScenarioSection(
    title: '0.4 Split view',
    scenarios: splitViewScenarios,
  ),
];
