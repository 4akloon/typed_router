// Every event of a shell's navigator reaches the root's observers, not only
// push and pop.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';
import 'package:typed_router_test/typed_router_test.dart';

import '../support/material_page_factory.dart';
import '../support/shell_fixtures.dart';
import '../support/tree_fixtures.dart';

/// Records the kinds of event it hears.
class _EventLog extends NavigatorObserver {
  final List<String> events = [];

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      events.add('replace');

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTop) =>
      events.add('change top');

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previous) =>
      events.add('start gesture');

  @override
  void didStopUserGesture() => events.add('stop gesture');
}

Future<(TypedRouter, _EventLog)> _pumpShell(WidgetTester tester) async {
  final log = _EventLog();
  final router = TypedRouter(
    routes: [
      ShellNode<NoParentRoute>(
        builder: (context, state, navigator) => navigator,
        children: [
          RouteNode<UsersRoute>(
            build: (context, users) => const Text('Users'),
            children: [
              RouteNode<UserRoute>(
                build: (context, user) => Text('User ${user.userId}'),
              ).withParent((user) => users),
            ],
          ),
        ],
      ),
    ],
    initialRoute: users,
    pageFactory: const MaterialPageFactory(),
    observers: [log],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return (router, log);
}

void main() {
  testWidgets("a shell's navigator relays replace and change of top", (
    tester,
  ) async {
    final (router, log) = await _pumpShell(tester);
    log.events.clear();
    await settleAfter(tester, () => router.push(user1).ignore());
    expect(log.events, contains('change top'));

    final shellNavigator = navigatorShowing(tester, 'User u1');
    final sheet = MaterialPageRoute<void>(builder: (context) => const Text(''));
    shellNavigator.push(sheet).ignore();
    await tester.pumpAndSettle();
    log.events.clear();
    shellNavigator.replace(
      oldRoute: sheet,
      newRoute: MaterialPageRoute<void>(builder: (context) => const Text('')),
    );
    await tester.pumpAndSettle();

    expect(log.events, contains('replace'));
  });

  testWidgets("a shell's navigator relays the iOS back swipe", (tester) async {
    final (router, log) = await _pumpShell(tester);
    await settleAfter(tester, () => router.push(user1).ignore());
    log.events.clear();

    await tester.iosEdgeSwipe();

    expect(log.events, containsAllInOrder(['start gesture', 'stop gesture']));
    expect(find.text('Users'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
