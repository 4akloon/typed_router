import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';

/// A Material demo app over the router [createRouter] makes: created when
/// the demo opens, disposed when it closes, as an app keeps its router.
class RouterDemo extends StatefulWidget {
  const RouterDemo({
    required this.frame,
    required this.createRouter,
    super.key,
  });

  final ScenarioFrame frame;

  /// Called once, when the demo opens.
  final TypedRouter Function() createRouter;

  @override
  State<RouterDemo> createState() => _RouterDemoState();
}

class _RouterDemoState extends State<RouterDemo> {
  late final TypedRouter _router = widget.createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: widget.frame.scenario.title,
    debugShowCheckedModeBanner: false,
    routerConfig: _router,
    builder: (context, app) => widget.frame.around(_router, app),
  );
}
