import 'package:flutter/material.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/scenarios/split_rooms.dart';
import 'package:typed_navigator_example/scenarios/split_routes.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const splitViewCustomLayoutScenario = Scenario(
  title: 'Split with a custom layout',
  summary: 'SplitNode.builder lays out split.columns itself.',
  instructions: [
    'The builder gets typed columns: a fixed 280-wide first column, '
        'dividers, and a label over each (RouteColumn or PlaceholderColumn).',
    'Up to three columns from 900 wide, two from 600, a stack below: '
        'push rooms to see the window shift.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () => TypedRouter(
    routes: splitRoomsRoutes(
      maximumColumns: (size) => switch (size.width) {
        >= 900 => 3,
        >= 600 => 2,
        _ => 1,
      },
      builder: (context, state, split) => _LabelledColumns(split.columns),
    ),
    initialRoute: const RoomsRoute(),
    pageFactory: const MaterialPageFactory(),
  ),
);

/// The columns in a row: the first 280 wide, the others sharing the rest,
/// each under a label naming its kind and route.
final class _LabelledColumns extends StatelessWidget {
  const _LabelledColumns(this.columns);

  final List<SplitColumn> columns;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (index, column) in columns.indexed) ...[
        if (index > 0) const VerticalDivider(width: 1),
        if (index == 0 && columns.length > 1)
          SizedBox(width: 280, child: _labelled(context, column))
        else
          Expanded(child: _labelled(context, column)),
      ],
    ],
  );

  Widget _labelled(BuildContext context, SplitColumn column) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        color: Theme.of(context).colorScheme.secondaryContainer,
        padding: const EdgeInsets.all(4),
        child: Text(switch (column) {
          RouteColumn(:final route) => 'RouteColumn: $route',
          PlaceholderColumn(:final route) => 'PlaceholderColumn of $route',
        }, style: Theme.of(context).textTheme.labelSmall),
      ),
      Expanded(child: column.child),
    ],
  );
}
