import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/scenarios/split_view_custom_layout_scenario.dart';
import 'package:typed_navigator_example/scenarios/split_view_list_detail_scenario.dart';
import 'package:typed_navigator_example/scenarios/split_view_miller_scenario.dart';

/// The split view demos, in catalogue order.
const List<Scenario> splitViewScenarios = [
  splitViewListDetailScenario,
  splitViewMillerScenario,
  splitViewCustomLayoutScenario,
];
