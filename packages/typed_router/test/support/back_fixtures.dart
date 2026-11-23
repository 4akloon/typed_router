// Apps for the back tests: guarded screens, Material rooms, dialogs opened
// imperatively.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';

import 'app_fixtures.dart';
import 'material_page_factory.dart';
import 'operation_fixtures.dart';
import 'route_fixtures.dart';

/// A form under rooms that refuses the back button.
class FormRoute extends TypedRoute<void> {
  const FormRoute();

  @override
  List<Object?> get fields => const [];
}

/// A first page that keeps the app open on back.
class ExitGuardRoute extends TypedRoute<void> {
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

/// A theme whose Android pages take predictive back gestures and whose iOS
/// pages keep the Cupertino back swipe. Made on each read: a theme takes
/// the test's platform when it is made.
ThemeData get predictiveBackTheme => ThemeData(
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
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

/// A Material app over [routes] with [predictiveBackTheme], started at the
/// account page with [pushed] pushed over it in order.
Future<TypedRouter> pumpPushedOverAccount(
  WidgetTester tester,
  List<TreeNode<NoParentRoute>> routes,
  List<TypedRoute<Object?>> pushed,
) async {
  final router = TypedRouter(
    routes: routes,
    initialRoute: const AccountRoute(),
    pageFactory: const MaterialPageFactory(),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(routerConfig: router, theme: predictiveBackTheme),
  );
  for (final route in pushed) {
    router.push(route).ignore();
    await tester.pumpAndSettle();
  }
  return router;
}
