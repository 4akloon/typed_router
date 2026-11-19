// Routes opened imperatively, PopScope and router operations.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/back_fixtures.dart';
import '../support/operation_fixtures.dart';

void main() {
  testWidgets('push over a dialog keeps the dialog under the new page', (
    tester,
  ) async {
    final router = await pumpMaterialRooms(tester);
    await pushAndSettle(tester, router, room7);
    final dialog = await openDialogOver(tester, 'Room 7');
    await pushAndSettle(tester, router, room8);

    expect(find.text('Room 8'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();

    expect(router.state.routes, const [rooms, room7]);
    expect(find.text('Dialog'), findsOneWidget);
    expect(dialog.isCompleted, isFalse);
  });

  testWidgets("go that removes a dialog's page removes the dialog with null", (
    tester,
  ) async {
    final router = await pumpMaterialRooms(tester);
    await pushAndSettle(tester, router, room7);
    final dialog = await openDialogOver(tester, 'Room 7');

    router.go(rooms);
    await tester.pumpAndSettle();

    expect(find.text('Dialog'), findsNothing);
    expect(router.state.routes, const [rooms]);
    expect(dialog.completions, [null]);
  });

  testWidgets('router operations do not ask PopScope', (tester) async {
    final attempts = <bool>[];
    final router = await pumpGuarded(tester, const FormRoute(), attempts);

    router.pop();
    await tester.pumpAndSettle();
    expect(router.state.routes, const [rooms]);

    router.go(const FormRoute());
    await tester.pumpAndSettle();
    router.go(rooms);
    await tester.pumpAndSettle();

    expect(router.state.routes, const [rooms]);
    expect(find.text('Rooms'), findsOneWidget);
    // Nothing was blocked; PopScope only hears that its page closed, as
    // with a native Navigator.pop.
    expect(attempts, [true, true]);
  });

  testWidgets('Navigator.maybePop from a screen works like the back button', (
    tester,
  ) async {
    final router = await pumpMaterialRooms(tester);
    final room = await pushAndSettle(tester, router, room7);

    await Navigator.maybePop(tester.element(find.text('Room 7')));
    await tester.pumpAndSettle();

    expect(router.state.routes, const [rooms]);
    expect(room.completions, [null]);
  });
}
