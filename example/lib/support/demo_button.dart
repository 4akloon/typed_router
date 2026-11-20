import 'package:material_ui/material_ui.dart';

/// A button of a `DemoPage`, labelled with what it does.
final class DemoButton extends StatelessWidget {
  const DemoButton(this.label, {required this.onPressed, super.key});

  final String label;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) =>
      FilledButton.tonal(onPressed: onPressed, child: Text(label));
}
