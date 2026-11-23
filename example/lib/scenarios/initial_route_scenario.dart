import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';
import 'package:typed_router_example/catalogue/scenario.dart';
import 'package:typed_router_example/catalogue/scenario_frame.dart';
import 'package:typed_router_example/support/demo_button.dart';
import 'package:typed_router_example/support/demo_page.dart';
import 'package:typed_router_example/support/material_page_factory.dart';
import 'package:typed_router_example/support/router_demo.dart';

const initialRouteScenario = Scenario(
  title: 'Initial route and deep links',
  summary: 'Start deep in the tree; a link is a go to a typed route.',
  instructions: [
    'The app starts at ArticleRoute(flutter, 3): State already holds '
        'Topics and the topic below it, so back walks up the tree.',
    'On Topics, the link buttons stand in for a link the app received: '
        'go(ArticleRoute(...)) builds the routes above the article.',
    'The router takes typed routes, not URLs: the app turns a link it '
        'receives into go or push.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () => TypedRouter(
    routes: _routes,
    initialRoute: const ArticleRoute('flutter', 3),
    pageFactory: const MaterialPageFactory(),
  ),
);

final List<TreeNode<NoParentRoute>> _routes = [
  RouteNode<TopicsRoute>(
    build: (context, topics) => const _TopicsPage(),
    children: [
      RouteNode<TopicRoute>(
        build: (context, topic) => DemoPage(
          title: 'Topic ${topic.name}',
          actions: [
            DemoButton(
              'open article 1',
              onPressed: () =>
                  TypedRouter.of(context).push(ArticleRoute(topic.name, 1)),
            ),
          ],
        ),
        children: [
          RouteNode<ArticleRoute>(
            build: (context, article) => DemoPage(
              title: 'Article ${article.number}',
              text: 'In topic ${article.topic}.',
              actions: const [],
            ),
          ).withParent((article) => TopicRoute(article.topic)),
        ],
      ).withParent((topic) => const TopicsRoute()),
    ],
  ),
];

class TopicsRoute extends TypedRoute<void> {
  const TopicsRoute();

  @override
  List<Object?> get fields => const [];
}

class TopicRoute extends TypedRoute<void> {
  const TopicRoute(this.name);

  final String name;

  @override
  List<Object?> get fields => [name];
}

class ArticleRoute extends TypedRoute<void> {
  const ArticleRoute(this.topic, this.number);

  final String topic;
  final int number;

  @override
  List<Object?> get fields => [topic, number];
}

class _TopicsPage extends StatelessWidget {
  const _TopicsPage();

  @override
  Widget build(BuildContext context) {
    final router = TypedRouter.of(context);
    return DemoPage(
      title: 'Topics',
      actions: [
        for (final topic in ['flutter', 'dart'])
          DemoButton(
            'open topic $topic',
            onPressed: () => router.push(TopicRoute(topic)),
          ),
        DemoButton(
          'link: dart, article 5',
          onPressed: () => router.go(const ArticleRoute('dart', 5)),
        ),
        DemoButton(
          'link: flutter, article 3',
          onPressed: () => router.go(const ArticleRoute('flutter', 3)),
        ),
      ],
    );
  }
}
