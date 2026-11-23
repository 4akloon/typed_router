// Observers and named nodes for the observer tests.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import 'app_fixtures.dart';

/// Records what it hears: `push rooms`, `pop room`, `push pageless`.
class LogObserver extends NavigatorObserver {
  final List<String> events = [];

  String _name(Route<dynamic> route) => switch (route.settings) {
    Page<Object?>(:final name) => name ?? 'unnamed',
    _ => 'pageless',
  };

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      events.add('push ${_name(route)}');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      events.add('pop ${_name(route)}');
}

/// A router over [routes] with [observer], in a WidgetsApp; disposed when
/// the test ends.
Future<TypedRouter> pumpObserved(
  WidgetTester tester,
  List<TreeNode<NoParentRoute>> routes,
  TypedRoute<Object?> initialRoute,
  NavigatorObserver observer,
) async {
  final router = TypedRouter(
    routes: routes,
    initialRoute: initialRoute,
    pageFactory: const TestPageFactory(),
    observers: [observer],
  );
  addTearDown(router.dispose);
  await pumpWidgetsRouter(tester, router);
  await tester.pumpAndSettle();
  return router;
}
