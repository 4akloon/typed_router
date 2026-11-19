// The system back button and what the platform hears.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';

import 'app_fixtures.dart';
import 'operation_fixtures.dart';
import 'route_fixtures.dart';

/// Presses the Android back button: the platform's `popRoute` message.
Future<void> systemBack(WidgetTester tester) async {
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      const MethodCall('popRoute'),
    ),
    (_) {},
  );
  await tester.pumpAndSettle();
}

/// Records what the app tells the platform on [SystemChannels.platform].
final class PlatformCalls {
  PlatformCalls(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger
      ..setMockMethodCallHandler(SystemChannels.platform, (call) async {
        calls.add(call);
        return null;
      });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
  }

  final List<MethodCall> calls = [];

  /// Whether the app asked the platform to close it.
  bool get closedApp =>
      calls.any((call) => call.method == 'SystemNavigator.pop');

  /// Every `setFrameworkHandlesBack` value, in order.
  List<Object?> get frameworkHandlesBack => [
    for (final call in calls)
      if (call.method == 'SystemNavigator.setFrameworkHandlesBack')
        call.arguments,
  ];
}

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

/// A Material app over the test app's routes, started at rooms.
Future<TypedRouter> pumpMaterialRooms(WidgetTester tester) async {
  final router = appRouter(rooms, pageFactory: const MaterialPageFactory());
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
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
