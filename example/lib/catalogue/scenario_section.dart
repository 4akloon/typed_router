import 'package:typed_navigator_example/catalogue/scenario.dart';

/// A heading of the catalogue and the scenarios under it.
///
/// Compared by identity: every section is a single `const` instance.
final class ScenarioSection {
  const ScenarioSection({
    required this.title,
    required this.scenarios,
    this.placeholder,
  });

  final String title;

  final List<Scenario> scenarios;

  /// What the catalogue says while [scenarios] is empty.
  final String? placeholder;

  @override
  String toString() => 'ScenarioSection($title, $scenarios)';
}
