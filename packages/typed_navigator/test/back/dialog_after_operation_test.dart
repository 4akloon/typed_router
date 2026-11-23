// An operation shows in the next frame, so a dialog shown in the same callback
// lands under the new page. The recipe: take the navigator before, show the
// dialog after the frame.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/back_fixtures.dart';
import '../support/operation_fixtures.dart';

bool _isDialogOnTop(WidgetTester tester) =>
    ModalRoute.of(
      tester.element(find.text('Dialog', skipOffstage: false)),
    )?.isCurrent ??
    false;

/// The recipe of the operations' dartdoc and the README.
void _showDialogAfterTheFrame(
  NavigatorState navigator,
  List<String?> completions,
) {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    showDialog<String>(
      context: navigator.context,
      builder: (context) => const Text('Dialog'),
    ).then(completions.add).ignore();
  });
}

Future<void> _closeDialog(WidgetTester tester) async {
  Navigator.of(tester.element(find.text('Dialog'))).pop('ok');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the recipe shows a dialog above the page an operation opened', (
    tester,
  ) async {
    final router = await pumpMaterialRooms(tester);
    final navigator = Navigator.of(tester.element(find.text('Rooms')));
    final completions = <String?>[];

    router.push(room7).ignore();
    _showDialogAfterTheFrame(navigator, completions);
    await tester.pumpAndSettle();

    expect(router.state.routes, const [rooms, room7]);
    expect(_isDialogOnTop(tester), isTrue);
    await _closeDialog(tester);
    expect(completions, ['ok']);
    expect(find.text('Room 7'), findsOneWidget);
  });

  testWidgets('the recipe after go, which removes the page it was called '
      'from', (tester) async {
    final router = await pumpMaterialRooms(tester);
    await pushAndSettle(tester, router, room7);
    final navigator = Navigator.of(tester.element(find.text('Room 7')));
    final completions = <String?>[];

    router.go(rooms);
    _showDialogAfterTheFrame(navigator, completions);
    await tester.pumpAndSettle();

    expect(router.state.routes, const [rooms]);
    expect(_isDialogOnTop(tester), isTrue);
    await _closeDialog(tester);
    expect(completions, ['ok']);
    expect(find.text('Rooms'), findsOneWidget);
  });

  testWidgets('without the recipe a dialog shown with the operation lands '
      'under the new page, unlike with Navigator.push', (tester) async {
    final router = await pumpMaterialRooms(tester);

    router.push(room7).ignore();
    showDialog<String>(
      context: tester.element(find.text('Rooms')),
      builder: (context) => const Text('Dialog'),
    ).ignore();
    await tester.pumpAndSettle();

    expect(_isDialogOnTop(tester), isFalse);
    expect(find.text('Room 7'), findsOneWidget);
  });
}
