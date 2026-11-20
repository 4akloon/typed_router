import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_section.dart';

/// The home screen: every scenario, grouped by the version that built it.
final class CataloguePage extends StatelessWidget {
  const CataloguePage({
    required this.sections,
    required this.onOpen,
    super.key,
  });

  final List<ScenarioSection> sections;

  final void Function(Scenario scenario) onOpen;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('typed_navigator scenarios')),
    body: ListView(
      children: [
        for (final section in sections) ...[
          _SectionHeading(section.title),
          for (final scenario in section.scenarios)
            ListTile(
              key: ValueKey(scenario.title),
              title: Text(scenario.title),
              subtitle: Text(scenario.summary),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onOpen(scenario),
            ),
        ],
      ],
    ),
  );
}

final class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}
