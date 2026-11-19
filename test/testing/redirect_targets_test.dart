// Targets for calling a redirect on its own.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/testing.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/redirect_fixtures.dart';
import '../support/route_fixtures.dart';

void main() {
  test('stateAfterGo builds the target with its ancestors and changes '
      'nothing', () {
    final router = sessionRouter(Session(isSignedIn: true));
    final notifications = NotificationCounter(router);

    final target = router.stateAfterGo(room7);

    expect(target.routes, const [rooms, room7]);
    expect(router.state.routes, const [HomeRoute()]);
    expect(notifications.count, 0);
  });

  test('stateAfterPush puts the route on the current stack', () {
    final router = sessionRouter(Session(isSignedIn: true))..go(room7);

    expect(router.stateAfterPush(editNote).routes, const [
      rooms,
      room7,
      editNote,
    ]);
    expect(router.state.routes, const [rooms, room7]);
  });

  test('targets need no mounting and run no redirects', () {
    final calls = <String>[];
    final router = sessionRouter(Session(), calls: calls);

    router
      ..stateAfterGo(room7)
      ..stateAfterPush(const AccountRoute());

    expect(calls, isEmpty);
  });

  testWidgets('a redirect called on a target answers as the navigation '
      'does', (tester) async {
    final session = Session();
    final router = sessionRouter(session);
    await pumpWidgetsRouter(tester, router);
    final context = tester.element(find.text('Home'));
    final roomsNode = sessionRoutes(
      session,
      [],
    ).whereType<RouteNode<RoomsRoute>>().single;

    final routerAnswer = sessionRedirect(session, [])(
      context,
      router.stateAfterPush(const AccountRoute()),
    );
    final nodeAnswer = roomsNode.redirect?.call(
      context,
      rooms,
      router.stateAfterPush(room7),
    );

    router.push(const AccountRoute()).ignore();
    expect(routerAnswer, router.state.top);
    router.pop();
    router.push(room7).ignore();
    expect(nodeAnswer, router.state.top);
    expect(nodeAnswer, const SignInRoute(returnTo: room7));
  });

  test('a target of a route without a node fails', () {
    final router = sessionRouter(Session());

    expect(() => router.stateAfterGo(routeWithoutNode), throwsArgumentError);
    expect(() => router.stateAfterPush(routeWithoutNode), throwsArgumentError);
  });
}
