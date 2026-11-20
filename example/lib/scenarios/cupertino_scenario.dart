import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/support/cupertino_page_factory.dart';

const cupertinoScenario = Scenario(
  title: 'Cupertino app',
  summary: 'CupertinoApp.router with CupertinoPageFactory.',
  instructions: [
    'Open a contact: the iOS slide; drag from the left edge to swipe back '
        '(a mouse drag works on desktop). Let go before half way to cancel.',
    '"Compose" has CupertinoPageFactory(fullscreenDialog: true) on its '
        'node: it slides up and has no swipe back.',
  ],
  build: _CupertinoDemo.new,
);

/// The Cupertino counterpart of `RouterDemo`.
final class _CupertinoDemo extends StatefulWidget {
  const _CupertinoDemo(this.frame);

  final ScenarioFrame frame;

  @override
  State<_CupertinoDemo> createState() => _CupertinoDemoState();
}

final class _CupertinoDemoState extends State<_CupertinoDemo> {
  final TypedRouter _router = TypedRouter(
    routes: [
      RouteNode<ContactsRoute>(
        build: (context, contacts) => const _ContactsPage(),
        children: [
          RouteNode<ContactRoute>(
            build: (context, contact) => _CupertinoScreen(
              title: contact.name,
              child: Text('A contact: ${contact.name}'),
            ),
          ).withParent((contact) => const ContactsRoute()),
        ],
      ),
      RouteNode<ComposeRoute>(
        pageFactory: const CupertinoPageFactory(fullscreenDialog: true),
        build: (context, compose) => _CupertinoScreen(
          title: 'Compose',
          child: CupertinoButton(
            onPressed: () => TypedRouter.of(context).pop(),
            child: const Text('Done'),
          ),
        ),
      ),
    ],
    initialRoute: const ContactsRoute(),
    pageFactory: const CupertinoPageFactory(),
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CupertinoApp.router(
    debugShowCheckedModeBanner: false,
    routerConfig: _router,
    builder: (context, app) => widget.frame.around(_router, app),
  );
}

final class _ContactsPage extends StatelessWidget {
  const _ContactsPage();

  @override
  Widget build(BuildContext context) {
    final router = TypedRouter.of(context);
    return _CupertinoScreen(
      title: 'Contacts',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final name in ['Ann', 'Bob'])
            CupertinoButton(
              onPressed: () => router.push(ContactRoute(name)),
              child: Text('Open $name'),
            ),
          CupertinoButton(
            onPressed: () => router.push(const ComposeRoute()),
            child: const Text('Compose'),
          ),
        ],
      ),
    );
  }
}

final class _CupertinoScreen extends StatelessWidget {
  const _CupertinoScreen({required this.title, required this.child});

  final String title;

  final Widget child;

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(middle: Text(title)),
    child: Center(child: child),
  );
}

final class ContactsRoute extends TypedRoute<void> {
  const ContactsRoute();

  @override
  List<Object?> get fields => const [];
}

final class ContactRoute extends TypedRoute<void> {
  const ContactRoute(this.name);

  final String name;

  @override
  List<Object?> get fields => [name];
}

final class ComposeRoute extends TypedRoute<void> {
  const ComposeRoute();

  @override
  List<Object?> get fields => const [];
}
