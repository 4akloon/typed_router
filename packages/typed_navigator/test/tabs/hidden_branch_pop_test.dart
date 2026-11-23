// A native pop of a shell page in a branch not on screen leaves the branch's
// kept stack, as a route page's pop does.: a shell in a hidden branch is off
// screen.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/tabs_fixtures.dart';

class _ListBranch {}

class _OtherBranch {}

class _ListRoute extends TypedRoute<void> {
  const _ListRoute();

  @override
  List<Object?> get fields => const [];
}

class _DetailRoute extends TypedRoute<void> {
  const _DetailRoute();

  @override
  List<Object?> get fields => const [];
}

class _OtherRoute extends TypedRoute<void> {
  const _OtherRoute();

  @override
  List<Object?> get fields => const [];
}

/// Tabs whose list branch opens a detail inside a shell with a frame.
final _routes = <TreeNode<NoParentRoute>>[
  StatefulShellNode(
    builder: (context, state, shell) => shell,
    branches: [
      BranchNode<_ListBranch>(
        initial: const _ListRoute(),
        children: [
          RouteNode<_ListRoute>(
            build: (context, route) => const Text('List'),
            children: [
              ShellNode<_ListRoute>(
                builder: (context, state, navigator) => Column(
                  children: [
                    const Text('Frame'),
                    Expanded(child: navigator),
                  ],
                ),
                children: [
                  RouteNode<_DetailRoute>(
                    build: (context, route) => const Text('Detail'),
                  ).withParent((detail) => const _ListRoute()),
                ],
              ),
            ],
          ),
        ],
      ),
      BranchNode<_OtherBranch>(
        initial: const _OtherRoute(),
        children: [
          RouteNode<_OtherRoute>(
            build: (context, route) => const Text('Other'),
          ),
        ],
      ),
    ],
  ),
];

void main() {
  testWidgets('a native pop of a shell page in a hidden branch leaves the '
      'kept stack', (tester) async {
    final router = TypedRouter(
      routes: _routes,
      initialRoute: const _ListRoute(),
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);
    final detail = ResultProbe(router.push(const _DetailRoute()));
    await tester.pumpAndSettle();
    final listNavigator = Navigator.of(tester.element(find.text('Frame')));
    await settled(tester, () => shellOf(tester).goBranch<_OtherBranch>());

    listNavigator.pop();
    await tester.pumpAndSettle();

    expect(router.state.toString(), isNot(contains('_DetailRoute')));
    expect(detail.completions, [null]);
    await settled(tester, () => shellOf(tester).goBranch<_ListBranch>());
    expect(tester.takeException(), isNull);
    expect(
      router.state.toString(),
      '{*_ListBranch: [_ListRoute()] | _OtherBranch: [_OtherRoute()]}',
    );
    expect(find.text('List'), findsOneWidget);
    expect(find.text('Frame'), findsNothing);
  });

  testWidgets('a page of a shell in a hidden branch takes no back gesture', (
    tester,
  ) async {
    final router = TypedRouter(
      routes: _routes,
      initialRoute: const _DetailRoute(),
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);
    final detail = tester.element(find.text('Detail'));
    expect(ModalRoute.of(detail)?.popDisposition, RoutePopDisposition.bubble);

    await settled(tester, () => shellOf(tester).goBranch<_OtherBranch>());

    expect(find.text('Other'), findsOneWidget);
    expect(ModalRoute.of(detail)?.popDisposition, RoutePopDisposition.doNotPop);
  });
}
