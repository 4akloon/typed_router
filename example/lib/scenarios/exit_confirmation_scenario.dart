import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/support/demo_button.dart';
import 'package:typed_navigator_example/support/demo_page.dart';
import 'package:typed_navigator_example/support/material_page_factory.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const exitConfirmationScenario = Scenario(
  title: 'Exit confirmation',
  summary: 'No onExit: the screen asks with PopScope and before its own go.',
  instructions: [
    'Open the draft and type something: it has unsaved changes.',
    'Press back (app bar, System back, Android back gesture): PopScope '
        'asks first; "Stay" keeps the page, "Leave" pops it. The iOS swipe '
        'is off while there are changes, as with the native Navigator.',
    '"Go home" is the screen\'s own navigation: it asks the same before '
        'calling go.',
    'With no changes, back and "Go home" leave at once.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () => TypedRouter(
    routes: [
      RouteNode<HomeRoute>(
        build: (context, home) => DemoPage(
          title: 'Home',
          actions: [
            DemoButton(
              'open the draft',
              onPressed: () => TypedRouter.of(context).push(const DraftRoute()),
            ),
          ],
        ),
      ),
      RouteNode<DraftRoute>(build: (context, draft) => const _DraftPage()),
    ],
    initialRoute: const HomeRoute(),
    pageFactory: const MaterialPageFactory(),
  ),
);

final class HomeRoute extends TypedRoute<void> {
  const HomeRoute();

  @override
  List<Object?> get fields => const [];
}

final class DraftRoute extends TypedRoute<void> {
  const DraftRoute();

  @override
  List<Object?> get fields => const [];
}

final class _DraftPage extends StatefulWidget {
  const _DraftPage();

  @override
  State<_DraftPage> createState() => _DraftPageState();
}

final class _DraftPageState extends State<_DraftPage> {
  bool _hasChanges = false;

  Future<bool> _confirmLeaving() async =>
      !_hasChanges ||
      (await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
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
            ),
          ) ??
          false);

  Future<void> _onBackBlocked() async {
    final isLeaving = await _confirmLeaving();
    if (isLeaving && mounted) Navigator.pop(context);
  }

  Future<void> _goHome() async {
    final isLeaving = await _confirmLeaving();
    if (isLeaving && mounted) TypedRouter.of(context).go(const HomeRoute());
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_hasChanges,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _onBackBlocked();
    },
    child: DemoPage(
      title: 'Draft',
      text: _hasChanges ? 'Unsaved changes.' : 'No changes.',
      actions: [
        TextField(
          decoration: const InputDecoration(hintText: 'Type to change'),
          onChanged: (text) => setState(() => _hasChanges = text.isNotEmpty),
        ),
        DemoButton('Go home', onPressed: _goHome),
      ],
    ),
  );
}
