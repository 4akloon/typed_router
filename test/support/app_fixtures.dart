// A small app for integration tests: screens, a route tree and page factories
// built on widgets.dart only.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import 'route_fixtures.dart';

/// A route whose node has its own page factory, like a create-room sheet.
final class CreateRoomRoute extends TypedRoute<void> {
  const CreateRoomRoute();

  @override
  List<Object?> get fields => const [];
}

/// The rooms list; stateful, so tests can see whether its state survives.
final class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => RoomsScreenState();
}

final class RoomsScreenState extends State<RoomsScreen> {
  @override
  Widget build(BuildContext context) => const Text('Rooms');
}

/// Rooms with a room and a create-room sheet under them, and a note
/// editor that returns the edited text.
final List<TreeNode<NoParentRoute>> appRoutes = [
  const RouteNode<EditNoteRoute>(build: _editNoteScreen),
  RouteNode<RoomsRoute>(
    build: (context, route) => const RoomsScreen(),
    children: [
      RouteNode<RoomRoute>(
        build: (context, room) => Text('Room ${room.id.value}'),
      ).withParent((room) => const RoomsRoute()),
      const RouteNode<CreateRoomRoute>(
        build: _createRoomScreen,
        pageFactory: SheetPageFactory(),
      ).withParent((createRoom) => const RoomsRoute()),
    ],
  ),
];

Widget _createRoomScreen(BuildContext context, CreateRoomRoute route) =>
    const Text('Create room');

Widget _editNoteScreen(BuildContext context, EditNoteRoute route) =>
    const Text('Edit note');

/// A page that needs nothing but widgets.dart.
class TestPage extends Page<Object?> {
  const TestPage({required this.child, super.key});

  final Widget child;

  /// A page-based route: it shows the child of the page it currently has,
  /// as MaterialPage does, so a page updated in place shows its new child.
  @override
  Route<Object?> createRoute(BuildContext context) => PageRouteBuilder<Object?>(
    settings: this,
    pageBuilder: (context, animation, secondaryAnimation) =>
        switch (ModalRoute.of(
          context,
        )?.settings) {
          final TestPage page => page.child,
          _ => child,
        },
  );
}

/// The kind of page [SheetPageFactory] creates.
final class SheetPage extends TestPage {
  const SheetPage({required super.child, super.key});
}

/// The router's factory in tests: [TestPage]s.
final class TestPageFactory implements PageFactory {
  const TestPageFactory();

  @override
  Page<Object?> createPage(PageRequest request) =>
      TestPage(key: request.key, child: request.child);
}

/// A node's own factory: [SheetPage]s.
final class SheetPageFactory implements PageFactory {
  const SheetPageFactory();

  @override
  Page<Object?> createPage(PageRequest request) =>
      SheetPage(key: request.key, child: request.child);
}

/// A factory that forgets to pass the request key.
final class KeylessPageFactory implements PageFactory {
  const KeylessPageFactory();

  @override
  Page<Object?> createPage(PageRequest request) =>
      TestPage(child: request.child);
}

/// A router over [appRoutes], disposed when the test ends.
TypedRouter appRouter(
  TypedRoute<Object?> initialRoute, {
  PageFactory pageFactory = const TestPageFactory(),
}) {
  final router = TypedRouter(
    routes: appRoutes,
    initialRoute: initialRoute,
    pageFactory: pageFactory,
  );
  addTearDown(router.dispose);
  return router;
}

/// Shows [router] in a [WidgetsApp.router]: no Material, no Cupertino.
Future<void> pumpWidgetsRouter(WidgetTester tester, TypedRouter router) =>
    tester.pumpWidget(
      WidgetsApp.router(routerConfig: router, color: const Color(0xFF000000)),
    );

/// The page whose screen shows [text], as the navigator holds it.
Object? pageShowing(WidgetTester tester, String text) => ModalRoute.of(
  tester.element(find.text(text, skipOffstage: false)),
)?.settings;
