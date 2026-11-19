// Tabs of a chat app: a rooms branch and a friends branch, an account page on
// the root navigator. Screens log their creation, so a test sees whether a
// branch kept them alive.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import 'app_fixtures.dart';
import 'route_fixtures.dart';

final class RoomsBranch {}

final class FriendsBranch {}

final class FriendsRoute extends TypedRoute<void> {
  const FriendsRoute();

  @override
  List<Object?> get fields => const [];
}

final class FriendRoute extends TypedRoute<String> {
  const FriendRoute(this.name);

  final String name;

  @override
  List<Object?> get fields => [name];
}

const friends = FriendsRoute();
const ann = FriendRoute('ann');

/// Records every screen created, by its text.
final class ScreenLog {
  final List<String> created = [];
}

final class LoggedScreen extends StatefulWidget {
  const LoggedScreen(this.text, this.log, {super.key});

  final String text;
  final ScreenLog log;

  @override
  State<LoggedScreen> createState() => _LoggedScreenState();
}

final class _LoggedScreenState extends State<LoggedScreen> {
  @override
  void initState() {
    super.initState();
    widget.log.created.add(widget.text);
  }

  @override
  Widget build(BuildContext context) => Text(widget.text);
}

/// The app's tree: tabs of rooms and friends, account on the root.
List<TreeNode<NoParentRoute>> tabsRoutes(
  ScreenLog log, {
  TypedRoute<Object?>? Function(BuildContext context, NavigationState target)?
  redirect,
}) => [
  StatefulShellNode(
    builder: (context, state, shell) => Column(
      children: [
        Text('Tab ${shell.currentIndex}'),
        Expanded(child: shell),
      ],
    ),
    redirect: redirect,
    branches: [
      BranchNode<RoomsBranch>(
        initial: const RoomsRoute(),
        children: [
          RouteNode<RoomsRoute>(
            build: (context, rooms) => LoggedScreen('Rooms', log),
            children: [
              RouteNode<RoomRoute>(
                build: (context, room) =>
                    LoggedScreen('Room ${room.id.value}', log),
              ).withParent((room) => const RoomsRoute()),
            ],
          ),
        ],
      ),
      BranchNode<FriendsBranch>(
        initial: friends,
        children: [
          RouteNode<FriendsRoute>(
            build: (context, friends) => LoggedScreen('Friends', log),
            children: [
              RouteNode<FriendRoute>(
                build: (context, friend) =>
                    LoggedScreen('Friend ${friend.name}', log),
              ).withParent((friend) => friends),
            ],
          ),
        ],
      ),
    ],
  ),
  RouteNode<AccountRoute>(build: (context, account) => const Text('Account')),
];

/// A router over [tabsRoutes] shown in a WidgetsApp; disposed when the
/// test ends.
Future<TypedRouter> pumpTabsApp(
  WidgetTester tester,
  TypedRoute<Object?> initialRoute, {
  ScreenLog? log,
  TypedRoute<Object?>? Function(BuildContext context, NavigationState target)?
  redirect,
}) async {
  final router = TypedRouter(
    routes: tabsRoutes(log ?? ScreenLog(), redirect: redirect),
    initialRoute: initialRoute,
    pageFactory: const TestPageFactory(),
  );
  addTearDown(router.dispose);
  await pumpWidgetsRouter(tester, router);
  return router;
}

/// The tabs' shell, on screen or covered by another page.
StatefulShell shellOf(WidgetTester tester) =>
    tester.widget(find.byType(StatefulShell, skipOffstage: false).first);

/// Runs [navigate] and lets the frame settle.
Future<void> settled(WidgetTester tester, void Function() navigate) {
  navigate();
  return tester.pumpAndSettle();
}
