// Back gestures on a page whose node has onExit: the page does not take them,
// as with PopScope(canPop: false).

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router_test/typed_router_test.dart';

import '../support/back_fixtures.dart';
import '../support/exit_fixtures.dart';
import '../support/operation_fixtures.dart';

void main() {
  testWidgets('predictive back gets no preview and asks on commit', (
    tester,
  ) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log, theme: predictiveBackTheme);
    final before = tester.getTopLeft(find.text('Room 7'));

    final gesture = await tester.startPredictiveBack();
    await gesture.moveTo(0.8);
    expect(tester.getTopLeft(find.text('Room 7')), before);
    expect(find.text('Rooms'), findsNothing);
    expect(log.asked, isEmpty);

    await gesture.commit();
    await tester.pumpAndSettle();
    expect(log.asked, const [room7]);
    expect(router.state.routes, const [rooms]);
    expect(find.text('Rooms'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('the iOS swipe does not start on a page with onExit', (
    tester,
  ) async {
    final log = ExitLog();
    final router = await pumpExitApp(tester, log, theme: predictiveBackTheme);

    await tester.iosEdgeSwipe();

    expect(log.asked, isEmpty);
    expect(router.state.routes, const [rooms, room7]);
    expect(find.text('Room 7'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
