// Back and the native navigator inside a shell.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/testing.dart';

import '../support/operation_fixtures.dart';
import '../support/shell_fixtures.dart';

Future<ResultProbe<String>> _openDialog(WidgetTester tester, String over) =>
    _settled(
      tester,
      showGeneralDialog<String>(
        context: tester.element(find.text(over)),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Text('Dialog'),
      ),
    );

Future<ResultProbe<T>> _settled<T>(
  WidgetTester tester,
  Future<T?> result,
) async {
  final probe = ResultProbe(result);
  await tester.pumpAndSettle();
  return probe;
}

void main() {
  testWidgets('back pops inside the shell first, then the shell, then leaves '
      'the app', (tester) async {
    final platform = PlatformNavigationLog(tester);
    final router = await pumpShellApp(tester, account);
    await settleAfter(tester, () => router.push(user1).ignore());
    await settleAfter(tester, () => router.push(user2).ignore());

    await tester.systemBack();
    expect(router.state.toString(), 'AccountRoute() > [UserRoute(u1)]');

    await tester.systemBack();
    expect(router.state.toString(), 'AccountRoute()');
    expect(platform.closedApp, isFalse);

    await tester.systemBack();
    expect(platform.closedApp, isTrue);
  });

  testWidgets('back closes a dialog over the shell page first', (
    tester,
  ) async {
    final router = await pumpShellApp(tester, user1);
    final dialog = await _openDialog(tester, 'User u1');

    await tester.systemBack();

    expect(dialog.completions, [null]);
    expect(router.state.toString(), '[UsersRoute() > UserRoute(u1)]');
    expect(find.text('User u1'), findsOneWidget);
  });

  testWidgets('PopScope inside a shell blocks back', (tester) async {
    final router = await pumpShellApp(tester, user1);
    await settleAfter(tester, () => router.push(editNote).ignore());

    await tester.systemBack();

    expect(
      router.state.toString(),
      '[UsersRoute() > UserRoute(u1) > EditNoteRoute()]',
    );
  });

  testWidgets('Navigator.pop inside a shell removes the page and completes '
      'its push', (tester) async {
    final router = await pumpShellApp(tester, user1);
    final note = await _settled(tester, router.push(editNote));

    Navigator.of(tester.element(find.text('Edit note'))).pop('Buy milk');
    await tester.pumpAndSettle();

    expect(router.state.toString(), '[UsersRoute() > UserRoute(u1)]');
    expect(note.completions, ['Buy milk']);
  });

  testWidgets('a pageless route in the shell navigator follows the native '
      'rules', (tester) async {
    final router = await pumpShellApp(tester, user1);
    final shellNavigator = navigatorShowing(tester, 'User u1');
    Future<ResultProbe<String>> openPageless() => _settled(
      tester,
      shellNavigator.push(
        PageRouteBuilder<String>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Text('Pageless'),
        ),
      ),
    );

    final first = await openPageless();
    await tester.systemBack();
    expect(first.completions, [null]);
    expect(router.state.toString(), '[UsersRoute() > UserRoute(u1)]');

    // go removes the page the route was opened over; the shell stays.
    final second = await openPageless();
    await settleAfter(tester, () => router.go(user2));
    expect(second.completions, [null]);
    expect(find.text('Pageless', skipOffstage: false), findsNothing);
    expect(router.state.toString(), '[UsersRoute() > UserRoute(u2)]');
  });
}
