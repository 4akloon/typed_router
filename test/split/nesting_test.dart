// Frames inside and around a split keep
// their state, and a cover cannot leave a split without columns.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/split_fixtures.dart';
import '../support/tabs_fixtures.dart' show friends, friendsBranch, roomsBranch;

Future<TypedRouter> _pump(
  WidgetTester tester,
  List<TreeNode<NoParentRoute>> routes,
  TypedRoute<Object?> initialRoute, {
  double width = 1000,
}) async {
  setWindowWidth(tester, width);
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

Widget _framed(String label, ScreenLog log, Widget child) => Column(
  children: [
    CountingScreen(label, log),
    Expanded(child: child),
  ],
);

void main() {
  testWidgets('the frames of a split and of a shell in it survive the '
      'width', (tester) async {
    final log = ScreenLog();
    await _pump(
      tester,
      [
        SplitNode<NoParentRoute>(
          maximumColumns: (size) => size.width >= 800 ? 2 : 1,
          builder: (context, state, split) => _framed('Split', log, split),
          children: [
            ShellNode<NoParentRoute>(
              builder: (context, state, navigator) =>
                  _framed('Shell', log, navigator),
              children: [
                RouteNode<RoomsRoute>(
                  build: (context, rooms) => CountingScreen('Rooms', log),
                ),
              ],
            ),
          ],
        ),
      ],
      rooms,
      width: 400,
    );
    await tapScreen(tester, 'Split');
    await tapScreen(tester, 'Shell');

    await resizeWindow(tester, 1000);

    expect(find.text('Split:1'), findsOneWidget);
    expect(find.text('Shell:1'), findsOneWidget);
    expect(log.created, ['Split', 'Shell', 'Rooms']);
  });

  testWidgets('tabs in a split keep their column and frame when the branch '
      'changes', (
    tester,
  ) async {
    final log = ScreenLog();
    final router = await _pump(tester, [
      SplitNode<NoParentRoute>(
        maximumColumns: (size) => 2,
        children: [
          StatefulShellNode(
            builder: (context, state, shell) => _framed('Tabs', log, shell),
            branches: [roomsBranch(log), friendsBranch(log)],
          ),
        ],
      ),
    ], rooms);
    await tapScreen(tester, 'Tabs');
    final column = navigatorOf(tester, 'Tabs');

    router.go(friends);
    await tester.pumpAndSettle();

    expect(find.text('Tabs:1'), findsOneWidget);
    expect(navigatorOf(tester, 'Tabs'), same(column));
  });

  testWidgets('a first route that covers the split is its first column', (
    tester,
  ) async {
    final router = await _pump(tester, [
      SplitNode<NoParentRoute>(
        maximumColumns: (size) => 2,
        builder: (context, state, split) =>
            Text('${split.columns.length} columns'),
        children: [
          RouteNode<RoomsRoute>(
            build: (context, rooms) => const Text('Rooms'),
            splitPresentation: SplitPresentation.cover,
          ),
        ],
      ),
    ], rooms);

    expect(find.text('1 columns'), findsOneWidget);
    expect(router.state.toString(), '[RoomsRoute()]');
  });
}
