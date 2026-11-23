// Router.pop closes a dialog above the page first, and canPop sees it, as
// Navigator.pop and go_router's pop do.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/shell_fixtures.dart';

Future<ResultProbe<String>> _dialogOver(
  WidgetTester tester,
  String text,
) async {
  final dialog = ResultProbe(
    showGeneralDialog<String>(
      context: tester.element(find.text(text)),
      useRootNavigator: false,
      pageBuilder: (context, animation, secondaryAnimation) =>
          const Text('Dialog'),
    ),
  );
  await tester.pumpAndSettle();
  return dialog;
}

void main() {
  testWidgets('pop closes a dialog above the page first', (tester) async {
    final router = appRouter(rooms);
    await pumpWidgetsRouter(tester, router);
    final room = ResultProbe(router.push(room7));
    await tester.pumpAndSettle();
    final dialog = await _dialogOver(tester, 'Room 7');

    router.pop('done');
    await tester.pumpAndSettle();

    expect(dialog.completions, ['done']);
    expect(find.text('Dialog'), findsNothing);
    expect(router.state.routes, const [rooms, room7]);
    expect(find.text('Room 7'), findsOneWidget);
    expect(room.isCompleted, isFalse);

    router.pop();
    await tester.pumpAndSettle();
    expect(router.state.routes, const [rooms]);
    expect(room.completions, [null]);
  });

  testWidgets("pop and canPop see a dialog in a shell's navigator", (
    tester,
  ) async {
    final router = await pumpShellApp(tester, users);
    expect(router.canPop, isFalse);
    final dialog = await _dialogOver(tester, 'Users');

    expect(router.canPop, isTrue);
    router.pop();
    await tester.pumpAndSettle();

    expect(dialog.completions, [null]);
    expect(find.text('Dialog'), findsNothing);
    expect(find.text('Users'), findsOneWidget);
    expect(router.canPop, isFalse);
  });

  testWidgets('pop closes a drawer (a local history entry) of the top page '
      'first, and canPop sees it', (tester) async {
    final router = appRouter(rooms);
    await pumpWidgetsRouter(tester, router);
    var isClosed = false;
    ModalRoute.of(
      tester.element(find.text('Rooms')),
    )?.addLocalHistoryEntry(LocalHistoryEntry(onRemove: () => isClosed = true));
    await tester.pumpAndSettle();

    expect(router.canPop, isTrue);
    router.pop();
    await tester.pumpAndSettle();

    expect(isClosed, isTrue);
    expect(router.state.routes, const [rooms]);
    expect(router.canPop, isFalse);
  });

  testWidgets('pop right after push removes the pushed page, not a dialog '
      'under it, as Navigator does', (tester) async {
    final router = appRouter(rooms);
    await pumpWidgetsRouter(tester, router);
    final dialog = await _dialogOver(tester, 'Rooms');

    final room = ResultProbe(router.push(room7));
    router.pop();
    await tester.pumpAndSettle();

    expect(router.state.routes, const [rooms]);
    expect(room.completions, [null]);
    expect(dialog.isCompleted, isFalse);
    expect(find.text('Dialog'), findsOneWidget);
  });
}
