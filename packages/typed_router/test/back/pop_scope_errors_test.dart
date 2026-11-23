// An error of an app's PopScope inside a pushed shell is reported, whichever
// way the pop came: through the shell's page it reaches the zone, through the
// system back button the framework reports it.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/back_fixtures.dart';
import '../support/shell_fixtures.dart';

Future<void> _pushFailingSheet(WidgetTester tester) async {
  navigatorShowing(tester, 'Users')
      .push(
        MaterialPageRoute<void>(
          builder: (context) => PopScope<Object?>(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) =>
                throw StateError('the app failed'),
            child: const Text('Sheet'),
          ),
        ),
      )
      .ignore();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an error of PopScope in a pushed shell is reported when the '
      "pop comes through the shell's page", (tester) async {
    final router = await pumpPushedOverAccount(
      tester,
      shellRoutes(FrameLog()),
      [
        users,
      ],
    );
    await _pushFailingSheet(tester);

    // The level's page hands the pop inside without awaiting it, as
    // Flutter's NavigatorPopHandler does: the error reaches the zone.
    final errors = <Object>[];
    await runZonedGuarded(
      () => router.navigator?.maybePop(),
      (error, stackTrace) => errors.add(error),
    );
    await tester.pumpAndSettle();

    expect(errors, [isStateError]);
    expect(find.text('Sheet'), findsOneWidget);
  });

  testWidgets('the same error is reported through system back', (
    tester,
  ) async {
    await pumpPushedOverAccount(tester, shellRoutes(FrameLog()), [users]);
    await _pushFailingSheet(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isStateError);
    expect(find.text('Sheet'), findsOneWidget);
  });
}
