// A placeholder may answer null for one route of its node.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/split_fixtures.dart';

/// Rooms and rooms inside rooms in a split of two columns; a room with an
/// odd number has no placeholder.
List<TreeNode<NoParentRoute>> _routes() => [
  SplitNode<NoParentRoute>(
    maximumColumns: (size) => 2,
    children: [
      RouteNode<RoomsRoute>(
        build: (context, rooms) => const Text('Rooms'),
        children: [
          RouteNode<RoomRoute>(
            build: (context, room) => Text('Room ${room.id.value}'),
            placeholder: (context, room) =>
                room.id.value.isEven ? Text('Pick in ${room.id.value}') : null,
          ).withParent((room) => const RoomsRoute()),
        ],
      ),
    ],
  ),
];

Future<TypedRouter> _pump(WidgetTester tester, TypedRoute<Object?> top) async {
  setWindowWidth(tester, 1000);
  final router = TypedRouter(
    routes: _routes(),
    initialRoute: top,
    pageFactory: const TestPageFactory(),
  );
  addTearDown(router.dispose);
  await pumpWidgetsRouter(tester, router);
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('a placeholder that answers null leaves no placeholder column '
      'for that route', (tester) async {
    final router = await _pump(tester, const RoomRoute(RoomId(1)));

    expect(find.textContaining('Pick in'), findsNothing);
    expect(find.text('Rooms'), findsOneWidget);
    expect(tester.getRect(find.text('Room 1')).left, 500);

    router.go(const RoomRoute(RoomId(2)));
    await tester.pumpAndSettle();

    expect(find.text('Pick in 2'), findsOneWidget);
    expect(find.text('Rooms'), findsNothing);
  });
}
