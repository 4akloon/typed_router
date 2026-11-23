import 'package:material_ui/material_ui.dart';

/// A screen of a demo: an app bar with [title], a short [text] and the
/// [actions] to try, one under another.
class DemoPage extends StatelessWidget {
  const DemoPage({
    required this.title,
    required this.actions,
    this.text,
    super.key,
  });

  final String title;

  final String? text;

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (text case final text?)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(text),
          ),
        for (final action in actions)
          Padding(padding: const EdgeInsets.only(bottom: 8), child: action),
      ],
    ),
  );
}
