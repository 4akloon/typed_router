// Marker interfaces and returning after sign-in need nothing beyond
// NavigationState and typed route fields.

import 'package:flutter_test/flutter_test.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/redirect_fixtures.dart';
import '../support/route_fixtures.dart';

void main() {
  testWidgets('a marker interface guards every marked route', (tester) async {
    final router = sessionRouter(Session());
    await pumpWidgetsRouter(tester, router);

    router.push(const AccountRoute()).ignore();
    expect(router.state.routes, const [
      HomeRoute(),
      SignInRoute(returnTo: AccountRoute()),
    ]);

    // go builds the marked ancestor, so its child is guarded too.
    router.go(const AccountSettingsRoute());
    expect(router.state.routes, const [
      SignInRoute(returnTo: AccountSettingsRoute()),
    ]);
  });

  testWidgets('sign-in returns to the guarded target', (tester) async {
    final session = Session();
    final router = sessionRouter(session);
    await pumpWidgetsRouter(tester, router);
    router.go(room7);
    await tester.pumpAndSettle();

    session.signIn();
    if (router.state.top case SignInRoute(returnTo: final returnTo?)) {
      router.go(returnTo);
    }
    await tester.pumpAndSettle();

    expect(router.state.routes, const [rooms, room7]);
    expect(find.text('Room 7'), findsOneWidget);
  });
}
