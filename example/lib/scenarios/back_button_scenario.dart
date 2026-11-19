import 'package:flutter/material.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/support/demo_button.dart';
import 'package:typed_navigator_example/support/demo_page.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const backButtonScenario = Scenario(
  title: 'System back',
  summary: 'Back closes dialogs first, PopScope blocks, the root exits.',
  instructions: [
    'Use Android\'s back button, or "System back" below on desktop and web.',
    'On Details, show a dialog and press back: the dialog closes, the page '
        'stays.',
    'Push the imperative page (Navigator.push): back closes it first; it '
        'is not in State, the top stays DetailsRoute().',
    'Turn on "Block back": back does nothing (PopScope); the app bar '
        'arrow is blocked too.',
    'Back on Home: nothing pops, Android closes the app.',
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
              'push Details',
              onPressed: () =>
                  TypedRouter.of(context).push(const DetailsRoute()),
            ),
          ],
        ),
      ),
      RouteNode<DetailsRoute>(
        build: (context, details) => const _DetailsPage(),
      ),
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

final class DetailsRoute extends TypedRoute<void> {
  const DetailsRoute();

  @override
  List<Object?> get fields => const [];
}

final class _DetailsPage extends StatefulWidget {
  const _DetailsPage();

  @override
  State<_DetailsPage> createState() => _DetailsPageState();
}

final class _DetailsPageState extends State<_DetailsPage> {
  bool _isBackBlocked = false;

  void _showDialog() => showDialog<void>(
    context: context,
    builder: (context) => const AlertDialog(
      title: Text('A dialog'),
      content: Text('Press back: this closes first.'),
    ),
  );

  void _pushImperativePage() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => const DemoPage(
        title: 'Imperative page',
        text: 'Pushed with Navigator.push: not a typed route.',
        actions: [],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_isBackBlocked,
    child: DemoPage(
      title: 'Details',
      actions: [
        DemoButton('Show a dialog', onPressed: _showDialog),
        DemoButton('Push an imperative page', onPressed: _pushImperativePage),
        SwitchListTile(
          title: const Text('Block back (PopScope canPop: false)'),
          value: _isBackBlocked,
          onChanged: (isBlocked) => setState(() => _isBackBlocked = isBlocked),
        ),
      ],
    ),
  );
}
