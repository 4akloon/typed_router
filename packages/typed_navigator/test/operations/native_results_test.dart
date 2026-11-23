// Results when the navigator itself closes a page.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_test/typed_navigator_test.dart';

import '../support/app_fixtures.dart';
import '../support/back_fixtures.dart';
import '../support/material_page_factory.dart';
import '../support/operation_fixtures.dart';

Future<TypedRouter> pumpRooms(WidgetTester tester, {ThemeData? theme}) async {
  final router = appRouter(rooms, pageFactory: const MaterialPageFactory());
  await tester.pumpWidget(
    MaterialApp.router(routerConfig: router, theme: theme),
  );
  return router;
}

void main() {
  testWidgets('a native Navigator.pop with a value completes the push with '
      'it', (tester) async {
    final router = await pumpRooms(tester);
    final note = ResultProbe(router.push(editNote));
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.text('Edit note'))).pop('Buy milk');
    await tester.pumpAndSettle();

    expect(router.state.routes, const [rooms]);
    expect(note.completions, ['Buy milk']);
    expect(find.text('Rooms'), findsOneWidget);
  });

  testWidgets(
    'a back gesture completes the push of the removed page with null',
    (tester) async {
      final router = await pumpRooms(tester, theme: predictiveBackTheme);
      final room = ResultProbe(router.push(room7));
      await tester.pumpAndSettle();

      await tester.predictiveBack();

      expect(router.state.routes, const [rooms]);
      expect(room.completions, [null]);
      expect(find.text('Rooms'), findsOneWidget);
      expect(find.text('Room 7'), findsNothing);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets('a dialog above the top page goes with it on pop and '
      'completes with null', (tester) async {
    final router = await pumpRooms(tester);
    unawaited(router.push(room7));
    await tester.pumpAndSettle();
    final dialog = ResultProbe(
      showDialog<String>(
        context: tester.element(find.text('Room 7')),
        builder: (context) => const Text('Dialog'),
      ),
    );
    await tester.pumpAndSettle();

    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('Dialog'), findsNothing);
    expect(router.state.routes, const [rooms]);
    expect(dialog.completions, [null]);
  });
}
