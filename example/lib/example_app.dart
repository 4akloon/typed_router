import 'package:material_ui/material_ui.dart';
import 'package:typed_router_example/catalogue/catalogue.dart';
import 'package:typed_router_example/catalogue/catalogue_page.dart';
import 'package:typed_router_example/catalogue/scenario.dart';
import 'package:typed_router_example/catalogue/scenario_frame.dart';

/// The example: the catalogue of scenarios, or the one scenario opened.
///
/// A scenario is a whole app of its own (`MaterialApp.router` over its own
/// `TypedRouter`), so the platform's back button and the root navigator
/// belong to it alone while it is open. Closing it disposes its router and
/// shows the catalogue again.
class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  Scenario? _openScenario;

  void _open(Scenario scenario) => setState(() => _openScenario = scenario);

  void _close() => setState(() => _openScenario = null);

  @override
  Widget build(BuildContext context) => switch (_openScenario) {
    final scenario? => KeyedSubtree(
      key: ObjectKey(scenario),
      child: scenario.build(ScenarioFrame(scenario: scenario, onClose: _close)),
    ),
    null => MaterialApp(
      title: 'typed_router',
      debugShowCheckedModeBanner: false,
      home: CataloguePage(sections: catalogue, onOpen: _open),
    ),
  };
}
