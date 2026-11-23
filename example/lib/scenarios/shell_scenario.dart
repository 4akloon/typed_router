import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/support/demo_button.dart';
import 'package:typed_navigator_example/support/demo_page.dart';
import 'package:typed_navigator_example/support/material_page_factory.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const shellScenario = Scenario(
  title: 'Shell with its own navigator',
  summary: 'ShellNode: a frame that stays while pages change inside it.',
  instructions: [
    'From Home, "go to the inbox" or "push the inbox": the mail frame '
        '(blue bar and the list on the left) is the shell; State shows its '
        'navigator in brackets.',
    'Tap letters in the list: the first is pushed into the shell\'s '
        'navigator, the next replaces it in place (no transition, the '
        'letter page is updated); the frame stays and reads the selected '
        'letter from the state.',
    'Back pops inside the shell first; on the inbox it leaves the shell '
        '(after push) or closes the app (after go).',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () => TypedRouter(
    routes: _routes,
    initialRoute: const HomeRoute(),
    pageFactory: const MaterialPageFactory(),
  ),
);

final List<TreeNode<NoParentRoute>> _routes = [
  RouteNode<HomeRoute>(
    build: (context, home) => DemoPage(
      title: 'Home',
      text: 'Outside the shell.',
      actions: [
        DemoButton(
          'go to the inbox',
          onPressed: () => TypedRouter.of(context).go(const InboxRoute()),
        ),
        DemoButton(
          'push the inbox',
          onPressed: () => TypedRouter.of(context).push(const InboxRoute()),
        ),
      ],
    ),
  ),
  ShellNode<NoParentRoute>(
    builder: (context, state, navigator) =>
        _MailFrame(selected: state.find<LetterRoute>(), navigator: navigator),
    children: [
      RouteNode<InboxRoute>(
        build: (context, inbox) => const DemoPage(
          title: 'Inbox',
          text: 'Pick a letter on the left.',
          actions: [],
        ),
        children: [
          RouteNode<LetterRoute>(
            build: (context, letter) => DemoPage(
              title: 'Letter ${letter.number}',
              actions: const [],
            ),
          ).withParent((letter) => const InboxRoute()),
        ],
      ),
    ],
  ),
];

class HomeRoute extends TypedRoute<void> {
  const HomeRoute();

  @override
  List<Object?> get fields => const [];
}

class InboxRoute extends TypedRoute<void> {
  const InboxRoute();

  @override
  List<Object?> get fields => const [];
}

class LetterRoute extends TypedRoute<void> {
  const LetterRoute(this.number);

  final int number;

  @override
  List<Object?> get fields => [number];
}

/// The shell's frame: a title bar and a list of letters around the
/// shell's [navigator].
class _MailFrame extends StatelessWidget {
  const _MailFrame({required this.selected, required this.navigator});

  final LetterRoute? selected;

  final Widget navigator;

  /// Pushes the first letter into the shell; a letter replaces another.
  void _open(TypedRouter router, int number) => selected == null
      ? router.push(LetterRoute(number))
      : router.replace(LetterRoute(number));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Mail (shell frame)'),
      backgroundColor: Colors.blue.shade100,
    ),
    body: Row(
      children: [
        SizedBox(
          width: 120,
          child: ListView(
            children: [
              for (final number in [1, 2, 3])
                ListTile(
                  title: Text('Letter $number'),
                  selected: selected?.number == number,
                  onTap: () => _open(TypedRouter.of(context), number),
                ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: navigator),
      ],
    ),
  );
}
