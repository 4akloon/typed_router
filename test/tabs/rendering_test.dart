// Hidden branches stop ticking, and the frames of shells and tabs stay in the
// semantics tree, as go_router renders them.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/shell_fixtures.dart';
import '../support/tabs_fixtures.dart';

/// Rotates for ever while its ticker is enabled.
final class _Spinner extends StatefulWidget {
  const _Spinner();

  @override
  State<_Spinner> createState() => _SpinnerState();
}

final class _SpinnerState extends State<_Spinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RotationTransition(turns: _rotation, child: const Text('Spinner'));
}

Future<TypedRouter> _pumpSpinningFriends(WidgetTester tester) async {
  final router = TypedRouter(
    routes: [
      StatefulShellNode(
        builder: (context, state, shell) => shell,
        branches: [
          BranchNode<RoomsBranch>(
            initial: const RoomsRoute(),
            children: [
              RouteNode<RoomsRoute>(build: (context, rooms) => const Text('')),
            ],
          ),
          BranchNode<FriendsBranch>(
            initial: friends,
            children: [
              RouteNode<FriendsRoute>(
                build: (context, friends) => const _Spinner(),
              ),
            ],
          ),
        ],
      ),
    ],
    initialRoute: friends,
    pageFactory: const TestPageFactory(),
  );
  addTearDown(router.dispose);
  await pumpWidgetsRouter(tester, router);
  return router;
}

void main() {
  testWidgets('a hidden tab stops ticking', (tester) async {
    await _pumpSpinningFriends(tester);

    shellOf(tester).goBranch<RoomsBranch>();
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('a tab ticks again when shown, with the same screen', (
    tester,
  ) async {
    await _pumpSpinningFriends(tester);
    final spinner = tester.state(find.byType(_Spinner));
    shellOf(tester).goBranch<RoomsBranch>();
    await tester.pump();
    expect(
      TickerMode.valuesOf(
        tester.element(find.byType(_Spinner, skipOffstage: false)),
      ).enabled,
      isFalse,
    );

    shellOf(tester).goBranch<FriendsBranch>();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.hasRunningAnimations, isTrue);
    expect(tester.state(find.byType(_Spinner)), same(spinner));
  });

  testWidgets('the frame of a shell is in the semantics tree', (tester) async {
    final semantics = tester.ensureSemantics();
    final router = await pumpShellApp(tester, user1);
    expect(find.bySemanticsLabel('Selected: u1'), findsOneWidget);

    await settleAfter(tester, () => router.push(user2).ignore());

    expect(find.bySemanticsLabel('Selected: u2'), findsOneWidget);
    expect(find.bySemanticsLabel('User u2'), findsOneWidget);
    expect(find.bySemanticsLabel('User u1'), findsNothing);
    semantics.dispose();
  });

  testWidgets('the frame of tabs is in the semantics tree, hidden branches '
      'are not', (tester) async {
    final semantics = tester.ensureSemantics();
    final router = await pumpTabsApp(tester, friends);
    await settled(tester, () => shellOf(tester).goBranch<RoomsBranch>());

    await settled(
      tester,
      () => router.push(const RoomRoute(RoomId(8))).ignore(),
    );

    expect(find.bySemanticsLabel('Tab 0'), findsOneWidget);
    expect(find.bySemanticsLabel('Room 8'), findsOneWidget);
    expect(find.bySemanticsLabel('Rooms'), findsNothing);
    expect(find.bySemanticsLabel('Friends'), findsNothing);
    semantics.dispose();
  });
}
