import 'package:flutter/widgets.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';

/// One entry of the catalogue: a small app showing one way to navigate.
///
/// Compared by identity: every scenario is a single `const` instance.
class Scenario {
  const Scenario({
    required this.title,
    required this.summary,
    required this.instructions,
    required this.build,
  });

  /// The name in the catalogue.
  final String title;

  /// One line under the title in the catalogue.
  final String summary;

  /// What to try and what should happen, one step per line; shown under
  /// the running demo.
  final List<String> instructions;

  /// Builds the demo's app; it passes its navigator through
  /// [ScenarioFrame.around] (the `builder` of `MaterialApp.router`).
  final Widget Function(ScenarioFrame frame) build;

  @override
  String toString() => 'Scenario($title)';
}
