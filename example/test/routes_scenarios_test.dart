import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/scenarios/back_button_scenario.dart';
import 'package:typed_navigator_example/scenarios/exit_confirmation_scenario.dart';
import 'package:typed_navigator_example/scenarios/observers_scenario.dart';
import 'package:typed_navigator_example/scenarios/redirect_error_scenario.dart';
import 'package:typed_navigator_example/scenarios/sign_in_guard_scenario.dart';
import 'package:typed_navigator_example/scenarios/typed_results_scenario.dart';
import 'package:typed_navigator_example/scenarios/typed_routes_scenario.dart';

import 'support/catalogue_driver.dart';

void main() {
  testWidgets('go builds the routes above a message, push does not', (
    tester,
  ) async {
    await startScenario(tester, typedRoutesScenario);
    await tapLabel(tester, 'go to help');

    await tapLabel(tester, 'push message 7/3');
    expect(shownState(tester), 'HelpRoute() > MessageRoute(7, 3)');

    await tapLabel(tester, 'Close demo');
    await openScenario(tester, typedRoutesScenario);
    await tapLabel(tester, 'go to help');
    await tapLabel(tester, 'go to message 7/3');
    expect(
      shownState(tester),
      'RoomsRoute() > RoomRoute(7) > MessageRoute(7, 3)',
    );
  });

  testWidgets('the edited name comes back as the typed result', (
    tester,
  ) async {
    await startScenario(tester, typedResultsScenario);
    await tapLabel(tester, 'Edit name');

    await tester.enterText(find.byType(TextField), 'Bob');
    await tapLabel(tester, 'Save with Navigator.pop');

    expect(find.textContaining('Name: Bob'), findsOneWidget);
    expect(find.textContaining('Last result of the push: "Bob"'), findsOne);
  });

  testWidgets('closing the demo while the editor is open drops its result', (
    tester,
  ) async {
    await startScenario(tester, typedResultsScenario);
    await tapLabel(tester, 'Edit name');

    await tapLabel(tester, 'Close demo');

    expect(tester.takeException(), isNull);
    expect(find.text('typed_navigator scenarios'), findsOneWidget);
  });

  testWidgets('system back on the first page reports that nothing popped', (
    tester,
  ) async {
    await startScenario(tester, backButtonScenario);
    await tapLabel(tester, 'push Details');
    await tapLabel(tester, 'System back');
    expect(shownState(tester), 'HomeRoute()');

    await tapLabel(tester, 'System back');

    expect(find.textContaining('Nothing popped'), findsOneWidget);
  });

  testWidgets('back on a changed draft asks before leaving', (tester) async {
    await startScenario(tester, exitConfirmationScenario);
    await tapLabel(tester, 'open the draft');
    await tester.enterText(find.byType(TextField), 'text');
    await tester.pump();

    await tapLabel(tester, 'System back');
    expect(find.text('Discard the draft?'), findsOneWidget);
    await tapLabel(tester, 'Leave');

    expect(shownState(tester), 'HomeRoute()');
  });

  testWidgets('signing in returns to the guarded route', (tester) async {
    await startScenario(tester, signInGuardScenario);
    await tapLabel(tester, 'open Admin');
    expect(shownState(tester), 'SignInRoute(AdminRoute())');

    await tapLabel(tester, 'Sign in');
    expect(shownState(tester), 'HomeRoute() > NotAllowedRoute()');

    await tapLabel(tester, 'System back');
    await tapLabel(tester, 'open Account');
    await tapLabel(tester, 'Sign out');
    expect(shownState(tester), 'SignInRoute(AccountRoute())');
  });

  testWidgets('a redirect loop shows the error screen until repaired', (
    tester,
  ) async {
    await startScenario(tester, redirectErrorScenario);

    await tapLabel(tester, 'Break the redirects');
    // The router reports what the redirects threw, then shows it.
    expect(tester.takeException(), isA<RedirectChainError>());
    expect(shownState(tester), contains('(error: '));
    expect(find.text('errorBuilder'), findsOneWidget);

    await tapLabel(tester, 'Repair');
    expect(shownState(tester), 'HomeRoute()');
  });

  testWidgets('the observer hears the shell and the router reports the '
      'typed top', (tester) async {
    await startScenario(tester, observersScenario);

    await tapLabel(tester, 'push RoomsRoute()');
    await tapLabel(tester, 'push RoomRoute()');

    expect(find.text('observer: push home'), findsOneWidget);
    expect(find.text('observer: push room'), findsOneWidget);
    expect(find.text('router: RoomRoute()'), findsOneWidget);
  });
}
