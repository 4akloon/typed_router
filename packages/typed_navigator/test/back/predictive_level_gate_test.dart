// A level's page refuses the back gesture while a page inside refuses it and
// while the level is off screen.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator_test/typed_navigator_test.dart';

import '../support/back_fixtures.dart';
import '../support/nested_level_fixtures.dart';
import '../support/operation_fixtures.dart' show editNote;
import '../support/shell_fixtures.dart' hide users;

final android = TargetPlatformVariant.only(TargetPlatform.android);

void main() {
  testWidgets('predictive back over a pushed shell whose only page refuses '
      'closes nothing', (tester) async {
    final router = await pumpPushedOverAccount(
      tester,
      shellRoutes(FrameLog()),
      [editNote],
    );

    await tester.predictiveBack();

    expect(router.state.toString(), 'AccountRoute() > [EditNoteRoute()]');
  }, variant: android);

  testWidgets('predictive back over a covered nested shell closes only the '
      'page on top', (tester) async {
    final router = await pumpMaterialAt(tester, nestedShellRoutes(), user1);
    router.push(account).ignore();
    await tester.pumpAndSettle();

    await tester.predictiveBack();

    expect(router.state.toString(), '[UsersRoute() > [UserRoute(u1)]]');
  }, variant: android);

  testWidgets('maybePop from the frame of a covered nested shell closes '
      'nothing', (tester) async {
    final router = await pumpMaterialAt(tester, nestedShellRoutes(), user1);
    router.push(account).ignore();
    await tester.pumpAndSettle();
    final frame = tester.element(find.text('User frame', skipOffstage: false));

    await Navigator.maybePop(frame);
    await tester.pumpAndSettle();

    expect(
      router.state.toString(),
      '[UsersRoute() > [UserRoute(u1)]] > AccountRoute()',
    );
  });
}
