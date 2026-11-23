// Re-checking the whole stack.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/redirect_fixtures.dart';

void main() {
  testWidgets('a refresh that redirects replaces the whole stack', (
    tester,
  ) async {
    final session = Session(isSignedIn: true);
    final router = sessionRouter(session, initialRoute: room7);
    await pumpWidgetsRouter(tester, router);
    final note = ResultProbe(router.push(editNote));
    await tester.pumpAndSettle();
    final dialog = ResultProbe(
      showGeneralDialog<String>(
        context: tester.element(find.text('Edit note')),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Text('Dialog'),
      ),
    );
    await tester.pumpAndSettle();

    session.signOut();
    await tester.pumpAndSettle();

    expect(router.state.routes, const [SignInRoute(returnTo: editNote)]);
    expect(note.completions, [null]);
    expect(dialog.completions, [null]);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('a refresh that redirects nowhere changes nothing', (
    tester,
  ) async {
    final session = Session(isSignedIn: true);
    final router = sessionRouter(session, initialRoute: room7);
    await pumpWidgetsRouter(tester, router);
    final notifications = NotificationCounter(router);

    session.signIn();

    expect(router.state.routes, const [rooms, room7]);
    expect(notifications.count, 0);
    await tester.pumpAndSettle();
    expect(find.text('Room 7'), findsOneWidget);
  });

  testWidgets('router.refresh re-checks the stack like a notification', (
    tester,
  ) async {
    var isClosed = false;
    final router = TypedRouter(
      routes: sessionRoutes(Session(isSignedIn: true), []),
      initialRoute: room7,
      pageFactory: const TestPageFactory(),
      redirect: (context, target) => isClosed ? const BannedRoute() : null,
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);

    isClosed = true;
    router.refresh();

    expect(router.state.routes, const [BannedRoute()]);
    await tester.pumpAndSettle();
    expect(find.text('Banned'), findsOneWidget);
  });

  testWidgets('rapid notifications each end in a checked state', (
    tester,
  ) async {
    final session = Session(isSignedIn: true);
    final router = sessionRouter(session, initialRoute: room7);
    await pumpWidgetsRouter(tester, router);
    final notifications = NotificationCounter(router);

    session
      ..signOut()
      ..ban()
      ..signIn();
    await tester.pumpAndSettle();

    expect(router.state.routes, const [BannedRoute()]);
    expect(notifications.count, 2);
    expect(find.text('Banned'), findsOneWidget);
    expect(find.text('Room 7', skipOffstage: false), findsNothing);
  });

  testWidgets('notifications while not shown or after dispose do nothing', (
    tester,
  ) async {
    final calls = <String>[];
    final session = Session(isSignedIn: true);
    final router = TypedRouter(
      routes: sessionRoutes(session, calls),
      initialRoute: room7,
      pageFactory: const TestPageFactory(),
      redirect: sessionRedirect(session, calls),
      refreshListenable: session,
    );

    session.signOut();
    expect(router.state.routes, const [rooms, room7]);
    expect(calls, isEmpty);

    router.dispose();
    expect(session.isListened, isFalse);
  });
}
