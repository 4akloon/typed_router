// A shell's navigator has a hero controller of its own, with the app's flight
// path, for as long as the shell lives.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/hero_fixtures.dart';
import '../support/shell_fixtures.dart';

void main() {
  testWidgets("a hero flies between two pages of a shell's navigator", (
    tester,
  ) async {
    final router = await pumpMaterialHeroes(tester, heroShellRoutes(), users);

    await pushHalfway(tester, router, user1);

    expect(isInFlight('avatar'), isTrue);
    await tester.pumpAndSettle();
    expect(isInFlight('avatar'), isFalse);
  });

  testWidgets("a nested flight follows the app's path: an arc in "
      'MaterialApp, a straight line in WidgetsApp', (tester) async {
    await pumpMaterialHeroes(tester, heroShellRoutes(), users);
    final arc = heroControllerOf(tester, 'avatar')?.createRectTween?.call(
      Rect.zero,
      const Rect.fromLTWH(10, 10, 10, 10),
    );
    expect(arc, isA<MaterialRectArcTween>());

    final router = TypedRouter(
      routes: heroShellRoutes(),
      initialRoute: users,
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);
    await tester.pumpAndSettle();
    final controller = heroControllerOf(tester, 'avatar');
    expect(controller, isNotNull);
    expect(controller?.createRectTween, isNull);
  });

  testWidgets('the controller of a shell that leaves the state is disposed; '
      'coming back, the shell gets a new one', (tester) async {
    final router = await pumpMaterialHeroes(tester, heroShellRoutes(), users);
    final first = heroControllerOf(tester, 'avatar');
    final disposed = <Object>[];
    void record(ObjectEvent event) {
      if (event is ObjectDisposed) disposed.add(event.object);
    }

    FlutterMemoryAllocations.instance.addListener(record);
    addTearDown(() => FlutterMemoryAllocations.instance.removeListener(record));

    await settleAfter(tester, () => router.go(account));
    expect(first, isNotNull);
    expect(disposed, contains(same(first)));

    await settleAfter(tester, () => router.go(users));
    expect(heroControllerOf(tester, 'avatar'), isNot(same(first)));
  });
}
