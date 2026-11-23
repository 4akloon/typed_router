import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/catalogue/system_back.dart';

/// The bottom panel of a running demo: what to try, the router's state as
/// it changes, a system back button for desktop and web, and the way back
/// to the catalogue.
class InstructionsPanel extends StatefulWidget {
  const InstructionsPanel({
    required this.frame,
    required this.router,
    super.key,
  });

  final ScenarioFrame frame;

  final TypedRouter router;

  @override
  State<InstructionsPanel> createState() => _InstructionsPanelState();
}

class _InstructionsPanelState extends State<InstructionsPanel> {
  bool _isExpanded = true;
  String? _backOutcome;

  Future<void> _sendSystemBack() async {
    final outcome = await SystemBack(widget.router).send();
    if (mounted) setState(() => _backOutcome = outcome);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _actions(theme),
              if (_isExpanded)
                for (final step in widget.frame.scenario.instructions)
                  Text('• $step', style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              _StateLine(router: widget.router),
              if (_backOutcome case final outcome?)
                Text(outcome, style: TextStyle(color: theme.colorScheme.error)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actions(ThemeData theme) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 4,
    children: [
      Text(widget.frame.scenario.title, style: theme.textTheme.titleSmall),
      TextButton(
        onPressed: _sendSystemBack,
        child: const Text('System back'),
      ),
      TextButton(
        onPressed: () => setState(() => _isExpanded = !_isExpanded),
        child: Text(_isExpanded ? 'Hide tips' : 'Show tips'),
      ),
      TextButton(
        onPressed: widget.frame.onClose,
        child: const Text('Close demo'),
      ),
    ],
  );
}

/// `State: RoomsRoute() > RoomRoute(7)`, rebuilt on every navigation.
class _StateLine extends StatelessWidget {
  const _StateLine({required this.router});

  final TypedRouter router;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: router,
    builder: (context, _) => Text(
      'State: ${router.state}',
      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
    ),
  );
}
