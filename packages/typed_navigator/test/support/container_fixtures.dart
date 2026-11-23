// Tabs framed by a container of the app: a spinner that ticks for ever, and
// tabs whose builder lays out `shell.navigators`.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import 'app_fixtures.dart';
import 'route_fixtures.dart';
import 'tabs_fixtures.dart';

/// Rotates for ever while its ticker is enabled.
class Spinner extends StatefulWidget {
  const Spinner({super.key});

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
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

/// The last shell the tabs' builder got, for tests whose container does
/// not put the shell itself in the tree.
class ShellCapture {
  StatefulShell? shell;

  /// The captured shell; fails the test when the builder has not run.
  StatefulShell get current => shell ?? (throw StateError('No shell built.'));
}

/// Rooms and friends tabs framed by [container] over `shell.navigators`,
/// with the account route; [friends] replaces the friends branch.
List<TreeNode<NoParentRoute>> containerRoutes(
  ShellCapture capture,
  Widget Function(StatefulShell shell) container, {
  ScreenLog? log,
  BranchNode<FriendsBranch>? friends,
}) {
  final screens = log ?? ScreenLog();
  return [
    StatefulShellNode(
      builder: (context, state, shell) {
        capture.shell = shell;
        return container(shell);
      },
      branches: [roomsBranch(screens), friends ?? friendsBranch(screens)],
    ),
    RouteNode<AccountRoute>(build: (context, account) => const Text('Account')),
  ];
}

/// A friends branch whose screen is a [Spinner].
final BranchNode<FriendsBranch> spinningFriends = BranchNode<FriendsBranch>(
  initial: const FriendsRoute(),
  children: [
    RouteNode<FriendsRoute>(build: (context, friends) => const Spinner()),
  ],
);

/// Shows only the active branch, leaving the others in the tree.
Widget offstageContainer(StatefulShell shell) => Stack(
  children: [
    for (final (index, navigator) in shell.navigators.indexed)
      Offstage(offstage: index != shell.currentIndex, child: navigator),
  ],
);

/// A WidgetsApp over [routes]; disposed when the test ends.
Future<TypedRouter> pumpContainerApp(
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
  return router;
}
