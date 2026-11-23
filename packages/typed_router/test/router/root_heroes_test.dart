// The root navigator has a hero controller when the app gives none, as
// go_router's does; an app's own stays.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';

import '../support/app_fixtures.dart';
import '../support/hero_fixtures.dart';
import '../support/shell_fixtures.dart';
import '../support/tree_fixtures.dart';

/// Users with a thumbnail and a user with a picture, on the root.
List<TreeNode<NoParentRoute>> _rootHeroRoutes() => [
  RouteNode<UsersRoute>(
    build: (context, users) => thumbnailPage('avatar'),
    children: [
      RouteNode<UserRoute>(
        build: (context, user) => detailPage('avatar'),
      ).withParent((user) => const UsersRoute()),
    ],
  ),
];

void main() {
  testWidgets('a hero flies in the root navigator of a WidgetsApp, in a '
      'straight line', (tester) async {
    final router = TypedRouter(
      routes: _rootHeroRoutes(),
      initialRoute: users,
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);
    await tester.pumpAndSettle();
    expect(heroControllerOf(tester, 'avatar')?.createRectTween, isNull);

    await pushHalfway(tester, router, user1);

    expect(isInFlight('avatar'), isTrue);
  });

  testWidgets("MaterialApp's own controller stays on the root navigator", (
    tester,
  ) async {
    await pumpMaterialHeroes(tester, _rootHeroRoutes(), users);
    final appController = HeroControllerScope.maybeOf(
      tester.element(find.byType(Router<Object>)),
    );

    expect(appController, isNotNull);
    expect(heroControllerOf(tester, 'avatar'), same(appController));
  });
}
