// Redirects that fail.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_test/typed_navigator_test.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/redirect_fixtures.dart';
import '../support/step_fixtures.dart';

void main() {
  final serviceDown = StateError('rooms service is down');
  Never failing(int number) => throw serviceDown;

  testWidgets('a redirect failing on an operation keeps the state and '
      'reports', (tester) async {
    final router = stepRouter(next: failing);
    await pumpWidgetsRouter(tester, router);
    final notifications = NotificationCounter(router);

    final step = ResultProbe(router.push(const StepRoute(0)));
    await tester.pump();

    expect(tester.takeException(), same(serviceDown));
    expect(router.state.routes, const [HomeRoute()]);
    expect(router.state.error, isNull);
    expect(step.completions, [null]);
    expect(notifications.count, 0);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Step 0', skipOffstage: false), findsNothing);

    final lost = stepRouter(next: (number) => routeWithoutNode);
    await pumpWidgetsRouter(tester, lost);
    lost.go(const StepRoute(0));
    expect(tester.takeException(), isA<ArgumentError>());
    expect(lost.state.routes, const [HomeRoute()]);
    await tester.pump();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('a redirect failing on mount or refresh shows the error '
      'screen', (tester) async {
    var isFailing = false;
    final router = stepRouter(
      next: (number) => isFailing ? failing(number) : null,
      initialRoute: const StepRoute(0),
      errorBuilder: (context, error) => Text('Failed: $error'),
    );
    await pumpWidgetsRouter(tester, router);
    expect(router.state.error, isNull);

    isFailing = true;
    router.refresh();
    await tester.pumpAndSettle();

    expect(tester.takeException(), same(serviceDown));
    expect(router.state.error, same(serviceDown));
    expect(router.state.routes, const [rooms, StepRoute(0)]);
    expect(find.text('Failed: $serviceDown'), findsOneWidget);
    expect(find.text('Step 0', skipOffstage: false), findsNothing);

    final mounted = stepRouter(next: failing, initialRoute: const StepRoute(1));
    await pumpWidgetsRouter(tester, mounted);
    await tester.pumpAndSettle();
    expect(tester.takeException(), same(serviceDown));
    expect(mounted.state.error, same(serviceDown));
  });

  testWidgets('back on the error screen closes the app', (tester) async {
    final platform = PlatformNavigationLog(tester);
    final router = stepRouter(next: failing, initialRoute: const StepRoute(0));
    await pumpWidgetsRouter(tester, router);
    tester.takeException();

    expect(router.canPop, isFalse);
    await tester.systemBack();

    expect(platform.closedApp, isTrue);
    expect(router.state.error, same(serviceDown));
    expect(find.textContaining('rooms service is down'), findsOneWidget);
  });

  testWidgets('without errorBuilder the built-in error screen shows the '
      'error', (tester) async {
    final router = stepRouter(next: failing, initialRoute: const StepRoute(0));
    await pumpWidgetsRouter(tester, router);
    tester.takeException();

    expect(find.textContaining('rooms service is down'), findsOneWidget);
  });

  testWidgets('a successful navigation clears the error', (tester) async {
    var isFailing = true;
    final router = stepRouter(
      next: (number) => isFailing ? failing(number) : null,
      initialRoute: const StepRoute(0),
    );
    await pumpWidgetsRouter(tester, router);
    tester.takeException();

    isFailing = false;
    router.go(const StepRoute(1));
    await tester.pumpAndSettle();

    expect(router.state.error, isNull);
    expect(router.state.routes, const [rooms, StepRoute(1)]);
    expect(find.text('Step 1'), findsOneWidget);
  });

  testWidgets('navigating from inside a redirect fails in debug', (
    tester,
  ) async {
    late final TypedRouter router;
    router = stepRouter(
      next: (number) {
        router.go(const HomeRoute());
        return null;
      },
    );
    await pumpWidgetsRouter(tester, router);

    router.go(const StepRoute(0));

    expect(tester.takeException(), isA<AssertionError>());
    expect(router.state.routes, const [HomeRoute()]);
  });
}
