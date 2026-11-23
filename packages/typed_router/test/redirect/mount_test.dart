// Redirects run once the router is shown.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/redirect_fixtures.dart';

void main() {
  testWidgets('a guarded deep link is redirected before the first frame', (
    tester,
  ) async {
    final router = sessionRouter(Session(), initialRoute: room7);

    await pumpWidgetsRouter(tester, router);

    expect(router.state.routes, const [SignInRoute(returnTo: room7)]);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Room 7', skipOffstage: false), findsNothing);
    expect(router.canPop, isFalse);
  });

  testWidgets('navigation before mounting runs no redirects until the '
      'router is shown', (tester) async {
    final calls = <String>[];
    final router = sessionRouter(Session(), calls: calls);

    router.go(room7);
    expect(router.state.routes, const [rooms, room7]);
    expect(calls, isEmpty);

    await pumpWidgetsRouter(tester, router);

    expect(router.state.routes, const [SignInRoute(returnTo: room7)]);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('showing the router again re-checks the stack', (tester) async {
    final session = Session(isSignedIn: true);
    final router = sessionRouter(session, initialRoute: room7);
    await pumpWidgetsRouter(tester, router);
    expect(router.state.routes, const [rooms, room7]);

    await tester.pumpWidget(const SizedBox());
    session.signOut();
    expect(router.state.routes, const [rooms, room7]);

    await pumpWidgetsRouter(tester, router);

    expect(router.state.top, isA<SignInRoute>());
    expect(find.text('Sign in'), findsOneWidget);
  });
}
