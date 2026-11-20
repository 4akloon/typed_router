import 'package:flutter/material.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/support/demo_button.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const observersScenario = Scenario(
  title: 'Observers and names',
  summary: 'NavigatorObserver on the router; RouteNode.name on the pages.',
  instructions: [
    'The log shows what a NavigatorObserver passed to TypedRouter hears '
        '(Sentry and analytics take one): the pages carry their node\'s '
        'name.',
    'Open the rooms shell and a room: the root observers hear the shell\'s '
        'navigator too, as go_router\'s do.',
    'The "router" lines are the typed recipe: listen to the router and '
        'read state.top.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) {
  final log = ValueNotifier<List<String>>(const []);
  // Observers hear a navigator while it builds, as with a plain Navigator:
  // show what they heard after the frame.
  void add(String line) => WidgetsBinding.instance.addPostFrameCallback(
    (timeStamp) => log.value = [...log.value, line],
  );
  return RouterDemo(
    frame: frame,
    createRouter: () {
      final router = TypedRouter(
        routes: _routes(log),
        initialRoute: const HomeRoute(),
        pageFactory: const MaterialPageFactory(),
        observers: [_LogObserver(add)],
      );
      router.addListener(() => add('router: ${router.state.top}'));
      return router;
    },
  );
}

List<TreeNode<NoParentRoute>> _routes(ValueNotifier<List<String>> log) => [
  RouteNode<HomeRoute>(
    name: 'home',
    build: (context, home) => _LogPage('Home', log, next: const RoomsRoute()),
  ),
  ShellNode<NoParentRoute>(
    builder: (context, state, navigator) => navigator,
    children: [
      RouteNode<RoomsRoute>(
        name: 'rooms',
        build: (context, rooms) =>
            _LogPage('Rooms', log, next: const RoomRoute()),
        children: [
          RouteNode<RoomRoute>(
            name: 'room',
            build: (context, room) => _LogPage('Room', log),
          ).withParent((room) => const RoomsRoute()),
        ],
      ),
    ],
  ),
];

/// Writes what it hears to the log.
final class _LogObserver extends NavigatorObserver {
  _LogObserver(this._add);

  final void Function(String line) _add;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _add('observer: push ${route.settings.name}');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _add('observer: pop ${route.settings.name}');
}

final class _LogPage extends StatelessWidget {
  const _LogPage(this.title, this.log, {this.next});

  final String title;
  final ValueNotifier<List<String>> log;
  final TypedRoute<Object?>? next;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Column(
      children: [
        if (next case final next?)
          DemoButton(
            'push $next',
            onPressed: () => TypedRouter.of(context).push(next),
          ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: log,
            builder: (context, lines, child) => ListView(
              children: [for (final line in lines.reversed) Text(line)],
            ),
          ),
        ),
      ],
    ),
  );
}

final class HomeRoute extends TypedRoute<void> {
  const HomeRoute();

  @override
  List<Object?> get fields => const [];
}

final class RoomsRoute extends TypedRoute<void> {
  const RoomsRoute();

  @override
  List<Object?> get fields => const [];
}

final class RoomRoute extends TypedRoute<void> {
  const RoomRoute();

  @override
  List<Object?> get fields => const [];
}
