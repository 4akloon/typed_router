// The router's observers on the root navigator, with the names of the nodes.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/observer_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/shell_fixtures.dart' show settleAfter;

List<TreeNode<NoParentRoute>> _routes() => [
  RouteNode<RoomsRoute>(
    name: 'rooms',
    build: (context, rooms) => const Text('Rooms'),
    children: [
      RouteNode<RoomRoute>(
        name: 'room',
        build: (context, room) => Text('Room ${room.id.value}'),
      ).withParent((room) => const RoomsRoute()),
    ],
  ),
  RouteNode<AccountRoute>(build: (context, account) => const Text('Account')),
];

void main() {
  testWidgets('a root observer hears pushes and pops of root pages with the '
      "node's name", (tester) async {
    final observer = LogObserver();
    final router = await pumpObserved(tester, _routes(), rooms, observer);

    await settleAfter(tester, () => router.push(room7).ignore());
    await settleAfter(tester, () => router.pop(null));

    expect(observer.events, ['push rooms', 'push room', 'pop room']);
  });

  testWidgets('a root observer hears a dialog', (tester) async {
    final observer = LogObserver();
    await pumpObserved(tester, _routes(), rooms, observer);

    showGeneralDialog<void>(
      context: tester.element(find.text('Rooms')),
      pageBuilder: (context, _, _) => const Text('Dialog'),
    ).ignore();
    await tester.pumpAndSettle();

    expect(observer.events.last, 'push pageless');
  });

  testWidgets('the page of a node without a name has no name', (
    tester,
  ) async {
    final observer = LogObserver();
    final router = await pumpObserved(tester, _routes(), rooms, observer);

    await settleAfter(tester, () => router.push(const AccountRoute()).ignore());

    expect(observer.events.last, 'push unnamed');
  });

  testWidgets('rebuilding the router attaches no observer twice', (
    tester,
  ) async {
    final observer = LogObserver();
    final router = await pumpObserved(tester, _routes(), rooms, observer);

    await pumpWidgetsRouter(tester, router);
    await settleAfter(tester, () => router.push(room7).ignore());
    await settleAfter(tester, () => router.go(room8));

    expect(tester.takeException(), isNull);
    expect(
      observer.events.where((event) => event == 'push room'),
      hasLength(2),
    );
  });
}
