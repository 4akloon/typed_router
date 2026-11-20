import 'package:flutter/widgets.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/framed_scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';

/// What the catalogue gives a running demo: its scenario and the way back
/// to the catalogue.
///
/// Compared by identity: the catalogue makes one each time a demo opens.
final class ScenarioFrame {
  const ScenarioFrame({required this.scenario, required this.onClose});

  final Scenario scenario;

  /// Closes the demo and shows the catalogue.
  final VoidCallback onClose;

  /// Puts [app] (what `MaterialApp.router` passes to its `builder`) above
  /// the panel with the instructions and [router]'s state.
  Widget around(TypedRouter router, Widget? app) => FramedScenario(
    frame: this,
    router: router,
    app: app ?? const SizedBox.shrink(),
  );

  @override
  String toString() => 'ScenarioFrame(${scenario.title})';
}
