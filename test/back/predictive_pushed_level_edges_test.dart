// A pushed level reads its navigators again when they change by themselves (a
// pageless route) and when another branch shows; a maybePop from its frame goes
// inside, as system back does.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/testing.dart';

import '../support/back_fixtures.dart';
import '../support/operation_fixtures.dart' show ResultProbe;
import '../support/route_fixtures.dart';
import '../support/shell_fixtures.dart';
import '../support/tabs_fixtures.dart';

final android = TargetPlatformVariant.only(TargetPlatform.android);

void main() {
  testWidgets('predictive back in a pushed shell closes a pageless route '
      'in it', (tester) async {
    final router = await pumpPushedOverAccount(
      tester,
      shellRoutes(FrameLog()),
      [users],
    );
    final sheet = ResultProbe(
      navigatorShowing(tester, 'Users').push(
        MaterialPageRoute<String>(builder: (context) => const Text('Sheet')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.predictiveBack();

    expect(sheet.completions, [null]);
    expect(router.state.toString(), 'AccountRoute() > [UsersRoute()]');
  }, variant: android);

  testWidgets('predictive back closes pushed tabs whose shown branch '
      'cannot pop', (tester) async {
    final router = await pumpPushedOverAccount(
      tester,
      tabsRoutes(ScreenLog()),
      [
        const RoomsRoute(),
      ],
    );
    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());
    await settled(tester, () => shellOf(tester).goBranch<RoomsBranch>());
    await settled(
      tester,
      () => router.push(const RoomRoute(RoomId(7))).ignore(),
    );
    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());

    await tester.predictiveBack();

    expect(router.state.toString(), 'AccountRoute()');
  }, variant: android);

  testWidgets('maybePop from the frame of a pushed shell closes its top '
      'page', (tester) async {
    final router = await pumpPushedOverAccount(
      tester,
      shellRoutes(FrameLog()),
      [users, user1],
    );

    await Navigator.maybePop(tester.element(find.text('Selected: u1')));
    await tester.pumpAndSettle();

    expect(router.state.toString(), 'AccountRoute() > [UsersRoute()]');
  });
}
