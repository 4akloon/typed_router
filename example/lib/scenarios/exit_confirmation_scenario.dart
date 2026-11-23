import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';
import 'package:typed_router_example/catalogue/scenario.dart';
import 'package:typed_router_example/catalogue/scenario_frame.dart';
import 'package:typed_router_example/support/demo_button.dart';
import 'package:typed_router_example/support/demo_page.dart';
import 'package:typed_router_example/support/material_page_factory.dart';
import 'package:typed_router_example/support/router_demo.dart';

const exitConfirmationScenario = Scenario(
  title: 'Exit confirmation',
  summary: 'onExit on the draft: back and every go ask before it leaves.',
  instructions: [
    'Open the draft and type something: it has unsaved changes.',
    'Press back (app bar, System back, Android back gesture): onExit asks; '
        '"Stay" keeps the page, "Leave" pops it. The page takes no back '
        'gesture, as with PopScope(canPop: false).',
    '"Go home" is a plain go, as a deep link or another feature would '
        'call it: onExit asks the same.',
    'With no changes, back and "Go home" leave at once.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () {
    final draft = _Draft();
    return TypedRouter(
      routes: [
        RouteNode<HomeRoute>(
          build: (context, home) => DemoPage(
            title: 'Home',
            actions: [
              DemoButton(
                'open the draft',
                onPressed: () =>
                    TypedRouter.of(context).push(const DraftRoute()),
              ),
            ],
          ),
        ),
        RouteNode<DraftRoute>(
          build: (context, route) => _DraftPage(draft),
          onExit: (context, route, target) async =>
              draft.text.isEmpty ||
              (await showDialog<bool>(
                    context: context,
                    builder: _discardDialog,
                  ) ??
                  false),
        ),
      ],
      initialRoute: const HomeRoute(),
      pageFactory: const MaterialPageFactory(),
    );
  },
);

class HomeRoute extends TypedRoute<void> {
  const HomeRoute();

  @override
  List<Object?> get fields => const [];
}

class DraftRoute extends TypedRoute<void> {
  const DraftRoute();

  @override
  List<Object?> get fields => const [];
}

/// The unsaved text, kept outside the screen so onExit can read it, as an
/// app's draft service.
class _Draft {
  String text = '';
}

Widget _discardDialog(BuildContext context) => AlertDialog(
  title: const Text('Discard the draft?'),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context, false),
      child: const Text('Stay'),
    ),
    TextButton(
      onPressed: () => Navigator.pop(context, true),
      child: const Text('Leave'),
    ),
  ],
);

class _DraftPage extends StatefulWidget {
  const _DraftPage(this.draft);

  final _Draft draft;

  @override
  State<_DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<_DraftPage> {
  @override
  void dispose() {
    widget.draft.text = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'Draft',
    text: widget.draft.text.isEmpty ? 'No changes.' : 'Unsaved changes.',
    actions: [
      TextField(
        decoration: const InputDecoration(hintText: 'Type to change'),
        onChanged: (text) => setState(() => widget.draft.text = text),
      ),
      DemoButton(
        'Go home',
        onPressed: () => TypedRouter.of(context).go(const HomeRoute()),
      ),
    ],
  );
}
