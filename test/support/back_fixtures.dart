// Apps for the back tests: guarded screens, Material rooms, dialogs opened
// imperatively.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';

import 'app_fixtures.dart';
import 'operation_fixtures.dart';
import 'route_fixtures.dart';

/// A form under rooms that refuses the back button.
final class FormRoute extends TypedRoute<void> {
  const FormRoute();

  @override
  List<Object?> get fields => const [];
}

/// A first page that keeps the app open on back.
final class ExitGuardRoute extends TypedRoute<void> {
  const ExitGuardRoute();

  @override
  List<Object?> get fields => const [];
}

/// Screens guarded by `PopScope(canPop: false)`; every back attempt is
/// added to [attempts] as its `didPop`.
List<TreeNode<NoParentRoute>> guardedRoutes(List<bool> attempts) {
  Widget guarded(String text) => PopScope<Object?>(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) => attempts.add(didPop),
    child: Text(text),
  );
  return [
    RouteNode<RoomsRoute>(
      build: (context, route) => const Text('Rooms'),
      children: [
        RouteNode<FormRoute>(
          build: (context, route) => guarded('Form'),
        ).withParent((form) => const RoomsRoute()),
      ],
    ),
    RouteNode<ExitGuardRoute>(build: (context, route) => guarded('Guard')),
  ];
}

/// A Material app over [guardedRoutes], started at [initialRoute].
Future<TypedRouter> pumpGuarded(
  WidgetTester tester,
  TypedRoute<Object?> initialRoute,
  List<bool> attempts,
) async {
  final router = TypedRouter(
    routes: guardedRoutes(attempts),
    initialRoute: initialRoute,
    pageFactory: const MaterialPageFactory(),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  return router;
}

/// A theme whose Android pages take predictive back gestures.
final ThemeData predictiveBackTheme = ThemeData(
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {TargetPlatform.android: PredictiveBackPageTransitionsBuilder()},
  ),
);

/// A Material app over the test app's routes, started at rooms.
Future<TypedRouter> pumpMaterialRooms(
  WidgetTester tester, {
  ThemeData? theme,
}) async {
  final router = appRouter(rooms, pageFactory: const MaterialPageFactory());
  await tester.pumpWidget(
    MaterialApp.router(routerConfig: router, theme: theme),
  );
  return router;
}

/// Opens a dialog over the screen showing [text]; its result is probed.
Future<ResultProbe<String>> openDialogOver(
  WidgetTester tester,
  String text,
) async {
  final probe = ResultProbe(
    showDialog<String>(
      context: tester.element(find.text(text)),
      builder: (context) => const Text('Dialog'),
    ),
  );
  await tester.pumpAndSettle();
  return probe;
}

/// Pushes [route] and lets its page settle.
Future<ResultProbe<Object?>> pushAndSettle(
  WidgetTester tester,
  TypedRouter router,
  TypedRoute<Object?> route,
) async {
  final probe = ResultProbe(router.push(route));
  await tester.pumpAndSettle();
  return probe;
}
