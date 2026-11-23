// On the error screen, an operation checks the whole stack it leads to; only a
// stack the redirects let through leaves the error screen.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/redirect_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/step_fixtures.dart';

/// A router at [HomeRoute] > [EditNoteRoute] on the error screen: its
/// redirect fails while `isFailing()`.
Future<TypedRouter> _onErrorScreen(
  WidgetTester tester,
  bool Function() isFailing,
  void Function() startFailing,
) async {
  final router = stepRouter(
    next: (number) => null,
    redirect: (context, target) =>
        isFailing() ? throw StateError('service down') : null,
    errorBuilder: (context, error) => const Text('Failed'),
  );
  await pumpWidgetsRouter(tester, router);
  router.push(const EditNoteRoute()).ignore();
  await tester.pumpAndSettle();
  startFailing();
  router.refresh();
  await tester.pumpAndSettle();
  expect(tester.takeException(), isStateError);
  expect(find.text('Failed'), findsOneWidget);
  return router;
}

void main() {
  testWidgets('an operation on the error screen re-checks the whole stack', (
    tester,
  ) async {
    var isFailing = false;
    final router = await _onErrorScreen(
      tester,
      () => isFailing,
      () => isFailing = true,
    );

    router.popUntil((route) => route is HomeRoute);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isStateError);
    expect(router.state.error, isNotNull);
    expect(router.state.routes, const [HomeRoute(), EditNoteRoute()]);
    expect(find.text('Failed'), findsOneWidget);

    router.push(const RoomsRoute()).ignore();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isStateError);
    expect(router.state.error, isNotNull);
    expect(find.text('Failed'), findsOneWidget);

    isFailing = false;
    router.popUntil((route) => route is HomeRoute);
    await tester.pumpAndSettle();
    expect(router.state.error, isNull);
    expect(router.state.routes, const [HomeRoute()]);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('pop on the error screen fails naming the error screen', (
    tester,
  ) async {
    var isFailing = false;
    final router = await _onErrorScreen(
      tester,
      () => isFailing,
      () => isFailing = true,
    );

    expect(router.canPop, isFalse);
    expect(
      router.pop,
      throwsA(
        isStateError.having(
          (error) => error.message,
          'message',
          contains('error screen'),
        ),
      ),
    );
  });

  testWidgets('a refresh the redirects pass leaves the error screen', (
    tester,
  ) async {
    var isFailing = false;
    final router = await _onErrorScreen(
      tester,
      () => isFailing,
      () => isFailing = true,
    );

    isFailing = false;
    router.refresh();
    await tester.pumpAndSettle();

    expect(router.state.error, isNull);
    expect(router.state.routes, const [HomeRoute(), EditNoteRoute()]);
    expect(find.text('Edit note'), findsOneWidget);
  });
}
