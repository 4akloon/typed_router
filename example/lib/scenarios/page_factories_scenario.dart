import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/support/demo_button.dart';
import 'package:typed_navigator_example/support/demo_page.dart';
import 'package:typed_navigator_example/support/fade_page_factory.dart';
import 'package:typed_navigator_example/support/material_page_factory.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const pageFactoriesScenario = Scenario(
  title: 'Page factories (Material)',
  summary: 'The router\'s factory, and a node\'s own for one route.',
  instructions: [
    '"Details" uses the router\'s MaterialPageFactory: the platform\'s '
        'slide, a back arrow.',
    '"Filters" has MaterialPageFactory(fullscreenDialog: true) on its '
        'node: a close button instead of the arrow; it slides up on iOS and '
        'macOS (Android\'s transition ignores the flag).',
    '"Preview" has the app\'s own FadePageFactory on its node: it fades.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () => TypedRouter(
    routes: [
      RouteNode<HomeRoute>(build: (context, home) => const _HomePage()),
      RouteNode<DetailsRoute>(
        build: (context, details) =>
            const DemoPage(title: 'Details', actions: []),
      ),
      RouteNode<FiltersRoute>(
        pageFactory: const MaterialPageFactory(fullscreenDialog: true),
        build: (context, filters) =>
            const DemoPage(title: 'Filters', actions: []),
      ),
      RouteNode<PreviewRoute>(
        pageFactory: const FadePageFactory(),
        build: (context, preview) =>
            const DemoPage(title: 'Preview', actions: []),
      ),
    ],
    initialRoute: const HomeRoute(),
    pageFactory: const MaterialPageFactory(),
  ),
);

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final router = TypedRouter.of(context);
    return DemoPage(
      title: 'Home',
      actions: [
        DemoButton(
          'push Details',
          onPressed: () => router.push(const DetailsRoute()),
        ),
        DemoButton(
          'push Filters',
          onPressed: () => router.push(const FiltersRoute()),
        ),
        DemoButton(
          'push Preview',
          onPressed: () => router.push(const PreviewRoute()),
        ),
      ],
    );
  }
}

class HomeRoute extends TypedRoute<void> {
  const HomeRoute();

  @override
  List<Object?> get fields => const [];
}

class DetailsRoute extends TypedRoute<void> {
  const DetailsRoute();

  @override
  List<Object?> get fields => const [];
}

class FiltersRoute extends TypedRoute<void> {
  const FiltersRoute();

  @override
  List<Object?> get fields => const [];
}

class PreviewRoute extends TypedRoute<void> {
  const PreviewRoute();

  @override
  List<Object?> get fields => const [];
}
