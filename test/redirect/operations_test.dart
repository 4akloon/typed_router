// What a redirect does to each operation.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/testing.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/redirect_fixtures.dart';

Future<TypedRouter> pumpSession(
  WidgetTester tester,
  Session session, {
  List<String>? calls,
}) async {
  final router = sessionRouter(session, calls: calls);
  await pumpWidgetsRouter(tester, router);
  return router;
}

void main() {
  testWidgets('go to a guarded route ends on the redirect target with one '
      'notification', (tester) async {
    final router = await pumpSession(tester, Session());
    final notifications = NotificationCounter(router);

    router.go(room7);
    await tester.pumpAndSettle();

    expect(router.state.routes, const [SignInRoute(returnTo: room7)]);
    expect(notifications.count, 1);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('push of a guarded route pushes the redirect target and '
      'completes with null', (tester) async {
    final router = await pumpSession(tester, Session());

    final room = ResultProbe(router.push(room7));
    await tester.pumpAndSettle();

    expect(router.state.routes, const [
      HomeRoute(),
      SignInRoute(returnTo: room7),
    ]);
    expect(room.completions, [null]);
    router.pop();
    expect(router.state.routes, const [HomeRoute()]);
  });

  testWidgets('replace and pushAndRemoveUntil put the redirect target in '
      'place of the route', (tester) async {
    final router = await pumpSession(tester, Session());
    router.push(editNote).ignore();

    final replaced = ResultProbe(router.replace(room7));
    expect(router.state.routes, const [
      HomeRoute(),
      SignInRoute(returnTo: room7),
    ]);

    final pushed = ResultProbe(
      router.pushAndRemoveUntil(room8, (route) => route is HomeRoute),
    );
    expect(router.state.routes, const [
      HomeRoute(),
      SignInRoute(returnTo: room8),
    ]);
    await tester.pumpAndSettle();
    expect([...replaced.completions, ...pushed.completions], [null, null]);
  });

  testWidgets('a redirect returning null or the target lets the navigation '
      'through', (tester) async {
    final router = await pumpSession(tester, Session(isSignedIn: true));
    router.go(room7);
    expect(router.state.routes, const [rooms, room7]);

    final session = Session()..ban();
    final banned = await pumpSession(tester, session);
    expect(banned.state.routes, const [BannedRoute()]);
    banned.go(const BannedRoute());
    expect(banned.state.routes, const [BannedRoute()]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pop, popUntil and platform back run no redirects', (
    tester,
  ) async {
    final calls = <String>[];
    final router = await pumpSession(
      tester,
      Session(isSignedIn: true),
      calls: calls,
    );
    router
      ..go(room7)
      ..push(room8).ignore()
      ..push(editNote).ignore()
      ..push(room7).ignore();
    await tester.pumpAndSettle();
    calls.clear();

    router
      ..pop()
      ..popUntil((route) => route == room8);
    await tester.pumpAndSettle();
    router.navigator?.pop();
    await tester.pumpAndSettle();
    await tester.systemBack();

    expect(router.state.routes, const [rooms]);
    expect(calls, isEmpty);
  });
}
