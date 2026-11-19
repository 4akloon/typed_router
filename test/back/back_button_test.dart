// The Android back button.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/testing.dart';

import '../support/back_fixtures.dart';
import '../support/operation_fixtures.dart';

void main() {
  testWidgets('the back button removes the top page and completes its push '
      'with null', (tester) async {
    final router = await pumpMaterialRooms(tester);
    final room = await pushAndSettle(tester, router, room7);
    final notifications = NotificationCounter(router);

    await tester.systemBack();

    expect(router.state.routes, const [rooms]);
    expect(notifications.count, 1);
    expect(room.completions, [null]);
    expect(find.text('Rooms'), findsOneWidget);
  });

  testWidgets('the back button closes a dialog above the top page first', (
    tester,
  ) async {
    final router = await pumpMaterialRooms(tester);
    await pushAndSettle(tester, router, room7);
    final dialog = await openDialogOver(tester, 'Room 7');

    await tester.systemBack();

    expect(find.text('Dialog'), findsNothing);
    expect(router.state.routes, const [rooms, room7]);
    expect(dialog.completions, [null]);
  });

  testWidgets('PopScope on the top page blocks the back button and hears '
      'about it', (tester) async {
    final attempts = <bool>[];
    final router = await pumpGuarded(tester, const FormRoute(), attempts);
    final platform = PlatformNavigationLog(tester);

    await tester.systemBack();

    expect(router.state.routes, const [rooms, FormRoute()]);
    expect(attempts, [false]);
    expect(platform.closedApp, isFalse);
  });

  testWidgets('the back button on the first page lets the platform close '
      'the app', (tester) async {
    final router = await pumpMaterialRooms(tester);
    final platform = PlatformNavigationLog(tester);

    await tester.systemBack();

    expect(platform.closedApp, isTrue);
    expect(router.state.routes, const [rooms]);
  });

  testWidgets('PopScope on the first page keeps the app open and hears about '
      'it', (tester) async {
    final attempts = <bool>[];
    await pumpGuarded(tester, const ExitGuardRoute(), attempts);
    final platform = PlatformNavigationLog(tester);

    await tester.systemBack();

    expect(platform.closedApp, isFalse);
    expect(attempts, [false]);
  });

  testWidgets('the back button walks a mixed stack in the native order', (
    tester,
  ) async {
    final router = await pumpMaterialRooms(tester);
    final platform = PlatformNavigationLog(tester);
    await pushAndSettle(tester, router, room7);
    await openDialogOver(tester, 'Room 7');
    await pushAndSettle(tester, router, room8);

    await tester.systemBack();
    expect(router.state.routes, const [rooms, room7]);
    expect(find.text('Dialog'), findsOneWidget);

    await tester.systemBack();
    expect(find.text('Dialog'), findsNothing);
    expect(router.state.routes, const [rooms, room7]);

    await tester.systemBack();
    expect(router.state.routes, const [rooms]);
    expect(platform.closedApp, isFalse);

    await tester.systemBack();
    expect(platform.closedApp, isTrue);
  });
}
