// A back gesture goes only to the page on screen, across shells, tabs and
// dialogs (flutter/flutter#152323).

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_test/typed_navigator_test.dart';

import '../support/back_fixtures.dart';
import '../support/material_page_factory.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/shell_fixtures.dart';
import '../support/tabs_fixtures.dart' hide settled;

final android = TargetPlatformVariant.only(TargetPlatform.android);
final iOS = TargetPlatformVariant.only(TargetPlatform.iOS);

const _tabsBefore =
    '{*RoomsBranch: [RoomsRoute() > RoomRoute(RoomId(7))] | '
    'FriendsBranch: [FriendsRoute() > FriendRoute(ann)]}';
const _tabsAfter =
    '{*RoomsBranch: [RoomsRoute()] | '
    'FriendsBranch: [FriendsRoute() > FriendRoute(ann)]}';

/// A Material app over [routes]; on Android its pages take predictive
/// back, on iOS they keep the Cupertino back swipe.
Future<TypedRouter> _pumpMaterial(
  WidgetTester tester,
  List<TreeNode<NoParentRoute>> routes,
  TypedRoute<Object?> initialRoute,
) async {
  final router = TypedRouter(
    routes: routes,
    initialRoute: initialRoute,
    pageFactory: const MaterialPageFactory(),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      theme: predictiveBackTheme,
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Future<TypedRouter> _shellUnderAccount(WidgetTester tester) async {
  final router = await _pumpMaterial(tester, shellRoutes(FrameLog()), user1);
  await settleAfter(tester, () => router.push(account).ignore());
  return router;
}

Future<TypedRouter> _tabsWithDeeperFriends(WidgetTester tester) async {
  final router = await _pumpMaterial(tester, tabsRoutes(ScreenLog()), ann);
  await settleAfter(tester, () => router.go(const RoomRoute(RoomId(7))));
  expect(router.state.toString(), _tabsBefore);
  return router;
}

void main() {
  testWidgets('predictive back over a shell closes only the root page', (
    tester,
  ) async {
    final router = await _shellUnderAccount(tester);

    await tester.predictiveBack();

    expect(router.state.toString(), '[UsersRoute() > UserRoute(u1)]');
    expect(find.text('User u1'), findsOneWidget);
  }, variant: android);

  testWidgets("predictive back in tabs closes only the active branch's page", (
    tester,
  ) async {
    final router = await _tabsWithDeeperFriends(tester);

    await tester.predictiveBack();

    expect(router.state.toString(), _tabsAfter);
    expect(find.text('Rooms'), findsOneWidget);
    expect(find.text('Room 7'), findsNothing);
  }, variant: android);

  testWidgets('predictive back with a dialog over a shell page closes the '
      'dialog', (tester) async {
    final router = await _pumpMaterial(tester, shellRoutes(FrameLog()), user1);
    final dialog = ResultProbe(
      showDialog<String>(
        context: tester.element(find.text('User u1')),
        builder: (context) => const Text('Dialog'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.predictiveBack();

    expect(dialog.completions, [null]);
    expect(router.state.toString(), '[UsersRoute() > UserRoute(u1)]');
    expect(find.text('Dialog'), findsNothing);
    expect(find.text('User u1'), findsOneWidget);
  }, variant: android);

  testWidgets('predictive back closes the shell page on screen', (
    tester,
  ) async {
    final router = await _pumpMaterial(tester, shellRoutes(FrameLog()), user1);

    await tester.predictiveBack();

    expect(router.state.toString(), '[UsersRoute()]');
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('User u1'), findsNothing);
  }, variant: android);

  testWidgets('an app PopScope on screen still blocks predictive back', (
    tester,
  ) async {
    final router = await _pumpMaterial(tester, shellRoutes(FrameLog()), user1);
    await settleAfter(tester, () => router.push(editNote).ignore());

    await tester.predictiveBack();

    expect(
      router.state.toString(),
      '[UsersRoute() > UserRoute(u1) > EditNoteRoute()]',
    );
    expect(find.text('Edit note'), findsOneWidget);
  }, variant: android);

  testWidgets('the iOS swipe closes only the page on screen', (tester) async {
    final shell = await _shellUnderAccount(tester);
    await tester.iosEdgeSwipe();
    expect(shell.state.toString(), '[UsersRoute() > UserRoute(u1)]');
    expect(find.text('User u1'), findsOneWidget);

    final tabs = await _tabsWithDeeperFriends(tester);
    await tester.iosEdgeSwipe();
    expect(tabs.state.toString(), _tabsAfter);
    expect(find.text('Rooms'), findsOneWidget);
  }, variant: iOS);
}
