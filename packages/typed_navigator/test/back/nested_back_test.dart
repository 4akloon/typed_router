// Back, PopScope and the iOS swipe at the edges of nested navigators; native
// behaviour, pinned by tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_test/typed_navigator_test.dart';

import '../support/material_page_factory.dart';
import '../support/route_fixtures.dart';
import '../support/shell_fixtures.dart';
import '../support/tabs_fixtures.dart' hide settled;

final android = TargetPlatformVariant.only(TargetPlatform.android);
final iOS = TargetPlatformVariant.only(TargetPlatform.iOS);

/// The tabs of [tabsRoutes] framed by [builder], with the account route.
List<TreeNode<NoParentRoute>> _tabsFramedBy(
  Widget Function(
    BuildContext context,
    NavigationState state,
    StatefulShell shell,
  )
  builder, {
  List<BranchNode<Object?>>? branches,
}) {
  final routes = tabsRoutes(ScreenLog());
  final tabs = routes.first as StatefulShellNode;
  return [
    StatefulShellNode(builder: builder, branches: branches ?? tabs.branches),
    ...routes.skip(1),
  ];
}

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
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('back on a tab root goes to the first tab with the PopScope '
      'recipe', (tester) async {
    final platform = PlatformNavigationLog(tester);
    final router = await _pumpMaterial(
      tester,
      _tabsFramedBy(
        (context, state, shell) => PopScope<Object?>(
          canPop: shell.currentIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) shell.goBranchAt(0);
          },
          child: shell,
        ),
      ),
      friends,
    );

    await tester.systemBack();
    expect(router.state.top, const RoomsRoute());
    expect(platform.closedApp, isFalse);

    await tester.systemBack();
    expect(platform.closedApp, isTrue);
  }, variant: android);

  testWidgets('PopScope on a branch root keeps the app open', (tester) async {
    final platform = PlatformNavigationLog(tester);
    final attempts = <bool>[];
    final router = await _pumpMaterial(
      tester,
      _tabsFramedBy(
        (context, state, shell) => shell,
        branches: [
          BranchNode<RoomsBranch>(
            initial: const RoomsRoute(),
            children: [
              RouteNode<RoomsRoute>(
                build: (context, rooms) => PopScope<Object?>(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) =>
                      attempts.add(didPop),
                  child: const Text('Rooms'),
                ),
              ),
            ],
          ),
        ],
      ),
      const RoomsRoute(),
    );

    await tester.systemBack();

    expect(platform.closedApp, isFalse);
    expect(attempts, [false]);
    expect(router.state.top, const RoomsRoute());
  }, variant: android);

  testWidgets('the iOS swipe on the first page of a shell above a root page '
      'removes the shell', (tester) async {
    final router = await _pumpMaterial(
      tester,
      shellRoutes(FrameLog()),
      account,
    );
    await settleAfter(tester, () => router.push(user1).ignore());
    expect(router.state.toString(), 'AccountRoute() > [UserRoute(u1)]');

    await tester.iosEdgeSwipe();

    expect(router.state.toString(), 'AccountRoute()');
    expect(find.text('Account'), findsOneWidget);
  }, variant: iOS);

  testWidgets('the iOS swipe on a tab root removes nothing', (tester) async {
    final router = await _pumpMaterial(
      tester,
      _tabsFramedBy((context, state, shell) => shell),
      const RoomsRoute(),
    );

    await tester.iosEdgeSwipe();

    expect(router.state.toString(), '{*RoomsBranch: [RoomsRoute()]}');
  }, variant: iOS);
}
