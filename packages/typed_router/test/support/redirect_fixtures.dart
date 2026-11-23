// Redirect scenarios of a chat app: a session that can sign out or be
// banned, a global redirect for the ban and AuthArea, and a guard on the rooms
// subtree. Every redirect call is logged to `calls`.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import 'app_fixtures.dart';
import 'route_fixtures.dart';

/// The signed-in user and the ban, as an app's auth and ban services.
class Session extends ChangeNotifier {
  Session({this._isSignedIn = false});

  bool _isSignedIn;
  bool _isBanned = false;

  bool get isSignedIn => _isSignedIn;
  bool get isBanned => _isBanned;

  /// Whether a router still listens to this session.
  bool get isListened => hasListeners;

  void signIn() => _change(() => _isSignedIn = true);
  void signOut() => _change(() => _isSignedIn = false);
  void ban() => _change(() => _isBanned = true);

  void _change(void Function() change) {
    change();
    notifyListeners();
  }
}

class HomeRoute extends TypedRoute<void> {
  const HomeRoute();

  @override
  List<Object?> get fields => const [];
}

class SignInRoute extends TypedRoute<void> {
  const SignInRoute({this.returnTo});

  /// Where to go after signing in.
  final TypedRoute<Object?>? returnTo;

  @override
  List<Object?> get fields => [returnTo];
}

class BannedRoute extends TypedRoute<void> {
  const BannedRoute();

  @override
  List<Object?> get fields => const [];
}

/// A child of the marked [AccountRoute]; not marked itself.
class AccountSettingsRoute extends TypedRoute<void> {
  const AccountSettingsRoute();

  @override
  List<Object?> get fields => const [];
}

/// The router's redirect: the ban first, then AuthArea for guests.
TypedRoute<Object?>? Function(BuildContext context, TypedRouterState target)
sessionRedirect(Session session, List<String> calls) => (context, target) {
  calls.add('router: ${target.top}');
  if (session.isBanned) return const BannedRoute();
  if (!session.isSignedIn && target.contains<AuthArea>()) {
    return SignInRoute(returnTo: target.top);
  }
  return null;
};

/// The app's tree; the rooms subtree sends guests to sign in.
List<TreeNode<NoParentRoute>> sessionRoutes(
  Session session,
  List<String> calls,
) => [
  RouteNode<HomeRoute>(build: (context, home) => const Text('Home')),
  RouteNode<SignInRoute>(build: (context, signIn) => const Text('Sign in')),
  RouteNode<BannedRoute>(build: (context, banned) => const Text('Banned')),
  const RouteNode<EditNoteRoute>(build: _editNoteScreen),
  RouteNode<AccountRoute>(
    build: (context, account) => const Text('Account'),
    children: [
      RouteNode<AccountSettingsRoute>(
        build: (context, settings) => const Text('Account settings'),
      ).withParent((settings) => const AccountRoute()),
    ],
  ),
  RouteNode<RoomsRoute>(
    build: (context, rooms) => const Text('Rooms'),
    redirect: (context, rooms, target) {
      calls.add('Rooms node: $rooms for ${target.top}');
      return session.isSignedIn ? null : SignInRoute(returnTo: target.top);
    },
    children: [
      RouteNode<RoomRoute>(
        build: (context, room) => Text('Room ${room.id.value}'),
        redirect: (context, room, target) {
          calls.add('Room node: $room for ${target.top}');
          return null;
        },
      ).withParent((room) => const RoomsRoute()),
    ],
  ),
];

Widget _editNoteScreen(BuildContext context, EditNoteRoute route) =>
    const Text('Edit note');

/// A router over [sessionRoutes] that re-checks when [session] changes;
/// disposed when the test ends.
TypedRouter sessionRouter(
  Session session, {
  TypedRoute<Object?> initialRoute = const HomeRoute(),
  List<String>? calls,
  Widget Function(BuildContext context, Object error)? errorBuilder,
}) {
  final log = calls ?? [];
  final router = TypedRouter(
    routes: sessionRoutes(session, log),
    initialRoute: initialRoute,
    pageFactory: const TestPageFactory(),
    redirect: sessionRedirect(session, log),
    refreshListenable: session,
    errorBuilder: errorBuilder,
  );
  addTearDown(router.dispose);
  return router;
}
