// The root navigator and the router from the widget tree.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';

import '../support/app_fixtures.dart';
import '../support/material_page_factory.dart';
import '../support/route_fixtures.dart';

Future<void> showDialogFrom(WidgetTester tester, TypedRouter router) async {
  if (router.navigator case final navigator?) {
    unawaited(
      showDialog<void>(
        context: navigator.context,
        builder: (context) => const Text('Dialog'),
      ),
    );
  }
  await tester.pumpAndSettle();
}

void main() {
  late TypedRouter router;

  setUp(() {
    router = appRouter(
      const RoomsRoute(),
      pageFactory: const MaterialPageFactory(),
    );
  });

  testWidgets('navigator is null until mounted, then shows dialogs over the '
      'top page', (tester) async {
    expect(router.navigator, isNull);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    final stateBefore = router.state;
    await showDialogFrom(tester, router);

    expect(router.navigator, isA<NavigatorState>());
    expect(find.text('Dialog'), findsOneWidget);
    expect(find.text('Rooms'), findsOneWidget);
    expect(router.state, stateBefore);
  });

  testWidgets('TypedRouter.of finds the router from a screen and from a '
      'dialog', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await showDialogFrom(tester, router);

    expect(TypedRouter.of(tester.element(find.text('Rooms'))), same(router));
    expect(TypedRouter.of(tester.element(find.text('Dialog'))), same(router));
  });

  testWidgets('TypedRouter.of without a router above throws a FlutterError', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox());

    expect(
      () => TypedRouter.of(tester.element(find.byType(SizedBox))),
      throwsFlutterError,
    );
  });
}
