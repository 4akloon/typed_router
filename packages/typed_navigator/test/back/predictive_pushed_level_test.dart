// A shell pushed over another root page gives the back gesture to its own
// navigators while they can pop; only then does the gesture close the whole
// level (flutter/flutter#152323).

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator_test/typed_navigator_test.dart';

import '../support/back_fixtures.dart';
import '../support/shell_fixtures.dart';

final android = TargetPlatformVariant.only(TargetPlatform.android);
final iOS = TargetPlatformVariant.only(TargetPlatform.iOS);

void main() {
  testWidgets('predictive back in a pushed shell closes its top page', (
    tester,
  ) async {
    final router = await pumpPushedOverAccount(
      tester,
      shellRoutes(FrameLog()),
      [users, user1],
    );
    expect(
      router.state.toString(),
      'AccountRoute() > [UsersRoute() > UserRoute(u1)]',
    );

    await tester.predictiveBack();

    expect(router.state.toString(), 'AccountRoute() > [UsersRoute()]');
    expect(find.text('Users'), findsOneWidget);
  }, variant: android);

  testWidgets('predictive back closes a pushed shell that cannot pop', (
    tester,
  ) async {
    final router = await pumpPushedOverAccount(
      tester,
      shellRoutes(FrameLog()),
      [users],
    );

    await tester.predictiveBack();

    expect(router.state.toString(), 'AccountRoute()');
  }, variant: android);

  testWidgets('the iOS swipe in a pushed shell closes its top page', (
    tester,
  ) async {
    final router = await pumpPushedOverAccount(
      tester,
      shellRoutes(FrameLog()),
      [users, user1],
    );

    await tester.iosEdgeSwipe();

    expect(router.state.toString(), 'AccountRoute() > [UsersRoute()]');
  }, variant: iOS);
}
