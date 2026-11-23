// A hero in flight lands when the shell's
// frame moves its navigator in the tree mid-flight (a builder that turns a
// column into a row).

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';

import '../support/hero_fixtures.dart';
import '../support/shell_fixtures.dart';
import '../support/tree_fixtures.dart';

/// Users and a user in a shell whose frame is a row while [isWide], a
/// column otherwise.
List<TreeNode<NoParentRoute>> _relayoutRoutes(ValueNotifier<bool> isWide) => [
  ShellNode<NoParentRoute>(
    builder: (context, state, navigator) => ValueListenableBuilder<bool>(
      valueListenable: isWide,
      builder: (context, wide, child) => wide
          ? Row(children: [Expanded(child: navigator)])
          : Column(children: [Expanded(child: navigator)]),
    ),
    children: [
      RouteNode<UsersRoute>(
        build: (context, users) => thumbnailPage('avatar'),
        children: [
          RouteNode<UserRoute>(
            build: (context, user) => detailPage('avatar'),
          ).withParent((user) => const UsersRoute()),
        ],
      ),
    ],
  ),
];

void main() {
  testWidgets("a hero in flight lands when the shell's frame moves the "
      'navigator', (tester) async {
    final isWide = ValueNotifier(false);
    addTearDown(isWide.dispose);
    final router = await pumpMaterialHeroes(
      tester,
      _relayoutRoutes(isWide),
      users,
    );
    await pushHalfway(tester, router, user1);

    isWide.value = true;
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('avatar detail')), findsOneWidget);
    expect(isInFlight('avatar'), isFalse);
  });
}
