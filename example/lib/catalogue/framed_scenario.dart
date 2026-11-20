import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/instructions_panel.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';

/// A running demo above its instructions panel.
final class FramedScenario extends StatelessWidget {
  const FramedScenario({
    required this.frame,
    required this.router,
    required this.app,
    super.key,
  });

  final ScenarioFrame frame;

  final TypedRouter router;

  final Widget app;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        // The panel below takes the bottom safe area.
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: app,
        ),
      ),
      InstructionsPanel(frame: frame, router: router),
    ],
  );
}
