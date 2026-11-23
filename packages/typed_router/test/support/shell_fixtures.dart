// An admin-like app: a list | detail shell around users and a note editor,
// an account page on the root navigator.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import 'app_fixtures.dart';
import 'route_fixtures.dart';
import 'tree_fixtures.dart';

const users = UsersRoute();
const user1 = UserRoute('u1');
const user2 = UserRoute('u2');
const account = AccountRoute();

/// Counts the frames the shell created: the same frame means the same
/// shell instance.
class FrameLog {
  int createdFrames = 0;
}

/// The list | detail frame: the selected user, then the shell navigator.
class ListDetailFrame extends StatefulWidget {
  const ListDetailFrame({
    required this.log,
    required this.selected,
    required this.navigator,
    super.key,
  });

  final FrameLog log;
  final UserRoute? selected;
  final Widget navigator;

  @override
  State<ListDetailFrame> createState() => _ListDetailFrameState();
}

class _ListDetailFrameState extends State<ListDetailFrame> {
  @override
  void initState() {
    super.initState();
    widget.log.createdFrames++;
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('Selected: ${widget.selected?.userId ?? 'none'}'),
      Expanded(child: widget.navigator),
    ],
  );
}

/// The app's tree; the note editor refuses back through PopScope.
List<TreeNode<NoParentRoute>> shellRoutes(
  FrameLog log, {
  TypedRoute<Object?>? Function(BuildContext context, TypedRouterState target)?
  shellRedirect,
}) => [
  ShellNode<NoParentRoute>(
    builder: (context, state, navigator) => ListDetailFrame(
      log: log,
      selected: state.find<UserRoute>(),
      navigator: navigator,
    ),
    redirect: shellRedirect,
    children: [
      RouteNode<UsersRoute>(
        build: (context, users) => const Text('Users'),
        children: [
          RouteNode<UserRoute>(
            build: (context, user) => Text('User ${user.userId}'),
          ).withParent((user) => const UsersRoute()),
        ],
      ),
      RouteNode<EditNoteRoute>(
        build: (context, note) =>
            const PopScope<Object?>(canPop: false, child: Text('Edit note')),
      ),
    ],
  ),
  RouteNode<AccountRoute>(build: (context, account) => const Text('Account')),
];

/// A router over [shellRoutes], shown in a WidgetsApp; disposed when the
/// test ends.
Future<TypedRouter> pumpShellApp(
  WidgetTester tester,
  TypedRoute<Object?> initialRoute, {
  FrameLog? log,
}) async {
  final router = TypedRouter(
    routes: shellRoutes(log ?? FrameLog()),
    initialRoute: initialRoute,
    pageFactory: const TestPageFactory(),
  );
  addTearDown(router.dispose);
  await pumpWidgetsRouter(tester, router);
  return router;
}

/// The navigator of the page showing [text].
NavigatorState navigatorShowing(WidgetTester tester, String text) =>
    Navigator.of(tester.element(find.text(text, skipOffstage: false)));

/// How many pages the root navigator has.
int rootPageCount(TypedRouter router) =>
    router.navigator?.widget.pages.length ?? 0;

/// Navigates with [navigate] and lets the frame settle.
Future<void> settleAfter(WidgetTester tester, void Function() navigate) {
  navigate();
  return tester.pumpAndSettle();
}
