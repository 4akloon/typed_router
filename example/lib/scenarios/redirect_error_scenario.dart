import 'package:flutter/material.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/support/demo_button.dart';
import 'package:typed_navigator_example/support/demo_page.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const redirectErrorScenario = Scenario(
  title: 'Redirect error screen',
  summary: 'A redirect loop shows errorBuilder; fixing it re-checks.',
  instructions: [
    '"Break the redirects" makes them loop between PingRoute and '
        'PongRoute, and re-checks the stack (refreshListenable).',
    'The loop is a RedirectChainError: the navigator shows the app\'s '
        'errorBuilder screen, State ends with (error: ...).',
    '"Repair" stops the loop and re-checks: the stack the redirects '
        'failed on comes back.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => _RedirectErrorDemo(frame);

final class _RedirectErrorDemo extends StatefulWidget {
  const _RedirectErrorDemo(this.frame);

  final ScenarioFrame frame;

  @override
  State<_RedirectErrorDemo> createState() => _RedirectErrorDemoState();
}

final class _RedirectErrorDemoState extends State<_RedirectErrorDemo> {
  /// Whether the redirects loop.
  final ValueNotifier<bool> _isBroken = ValueNotifier(false);

  @override
  void dispose() {
    _isBroken.dispose();
    super.dispose();
  }

  TypedRouter _createRouter() => TypedRouter(
    routes: [
      RouteNode<HomeRoute>(
        build: (context, home) => DemoPage(
          title: 'Home',
          actions: [
            DemoButton(
              'Break the redirects',
              onPressed: () => _isBroken.value = true,
            ),
          ],
        ),
      ),
      RouteNode<PingRoute>(build: (context, ping) => const Text('Ping')),
      RouteNode<PongRoute>(build: (context, pong) => const Text('Pong')),
    ],
    initialRoute: const HomeRoute(),
    pageFactory: const MaterialPageFactory(),
    refreshListenable: _isBroken,
    redirect: (context, target) => switch (target.top) {
      _ when !_isBroken.value => null,
      PingRoute() => const PongRoute(),
      _ => const PingRoute(),
    },
    errorBuilder: (context, error) => Scaffold(
      appBar: AppBar(title: const Text('errorBuilder')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Navigation failed:\n$error'),
          const SizedBox(height: 16),
          DemoButton('Repair', onPressed: () => _isBroken.value = false),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) =>
      RouterDemo(frame: widget.frame, createRouter: _createRouter);
}

final class HomeRoute extends TypedRoute<void> {
  const HomeRoute();

  @override
  List<Object?> get fields => const [];
}

final class PingRoute extends TypedRoute<void> {
  const PingRoute();

  @override
  List<Object?> get fields => const [];
}

final class PongRoute extends TypedRoute<void> {
  const PongRoute();

  @override
  List<Object?> get fields => const [];
}
