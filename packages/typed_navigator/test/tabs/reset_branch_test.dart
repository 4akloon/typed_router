// Resetting a branch, as go_router's
// `goBranch(index, initialLocation: true)`: resetting a branch keeps the
// screens its initial chain shares with the branch's stack.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/nested_tabs_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/tabs_fixtures.dart';

/// Tabs whose rooms branch starts at room 7, two routes deep.
List<TreeNode<NoParentRoute>> _deepInitial(ScreenLog log) => [
  StatefulShellNode(
    builder: (context, state, shell) => shell,
    branches: [
      BranchNode<RoomsBranch>(
        initial: room7,
        children: roomsBranch(log).children,
      ),
      friendsBranch(log),
    ],
  ),
];

Future<TypedRouter> _pump(
  WidgetTester tester,
  List<TreeNode<NoParentRoute>> routes,
  TypedRoute<Object?> initialRoute,
) async {
  final router = TypedRouter(
    routes: routes,
    initialRoute: initialRoute,
    pageFactory: const TestPageFactory(),
  );
  addTearDown(router.dispose);
  await pumpWidgetsRouter(tester, router);
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('resetting the active branch on its initial route recreates '
      'nothing', (tester) async {
    final log = ScreenLog();
    final router = await pumpTabsApp(tester, rooms, log: log);

    await settled(tester, () => shellOf(tester).resetBranchAt(0));

    expect(router.state.routes, const [rooms]);
    expect(log.created, ['Rooms']);
  });

  testWidgets('resetting the active branch keeps the screen of its initial '
      'route', (tester) async {
    final log = ScreenLog();
    final router = await pumpTabsApp(tester, room7, log: log);

    await settled(tester, () => shellOf(tester).resetBranch<RoomsBranch>());

    expect(router.state.routes, const [rooms]);
    expect(log.created, ['Rooms', 'Room 7']);
  });

  testWidgets('resetting another branch keeps the screen of its initial '
      'route', (tester) async {
    final log = ScreenLog();
    final router = await pumpTabsApp(tester, ann, log: log);
    await settled(tester, () => shellOf(tester).goBranchAt(0));

    await settled(tester, () => shellOf(tester).resetBranchAt(1));

    expect(router.state.routes, const [friends]);
    expect(log.created.where((text) => text == 'Friends'), hasLength(1));
  });

  testWidgets('resetting to a deeper initial route keeps the shared screens '
      'and builds the rest', (tester) async {
    final log = ScreenLog();
    final router = await _pump(tester, _deepInitial(log), room8);

    await settled(tester, () => shellOf(tester).resetBranchAt(0));

    expect(router.state.routes, const [rooms, room7]);
    expect(log.created, ['Rooms', 'Room 8', 'Room 7']);
  });

  testWidgets('resetting a branch that starts in nested tabs keeps them, as '
      'go does', (tester) async {
    final router = await _pump(tester, nestedTabsRoutes(ScreenLog()), ann);

    await settled(
      tester,
      () => shellWith(tester, OuterAccount).resetBranchAt(0),
    );

    expect(
      router.state.toString(),
      '{*OuterRooms: [{*RoomsBranch: [RoomsRoute()] | '
      'FriendsBranch: [FriendsRoute() > FriendRoute(ann)]}]}',
    );
  });
}
