// Replace updates in place only when the new page can update the one shown, and
// replace / pushReplacement of the only entry go to the route, as go_router's
// do when nothing is left below.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/tabs_fixtures.dart';

/// One factory, two kinds of page: a sheet for nodes named 'sheet'.
class _NamedSheetFactory implements PageFactory {
  const _NamedSheetFactory();

  @override
  Page<Object?> createPage(PageRequest request) => request.name == 'sheet'
      ? SheetPage(key: request.key, name: request.name, child: request.child)
      : TestPage(key: request.key, name: request.name, child: request.child);
}

void main() {
  testWidgets('replace with a page the shown one cannot update shows a new '
      'page, whatever the factory', (tester) async {
    final router = TypedRouter(
      routes: [
        RouteNode<RoomsRoute>(
          build: (context, rooms) => const Text('Rooms'),
          children: [
            RouteNode<RoomRoute>(
              build: (context, room) => Text('Room ${room.id.value}'),
            ).withParent((room) => const RoomsRoute()),
            RouteNode<CreateRoomRoute>(
              name: 'sheet',
              build: (context, create) => const Text('Create room'),
            ).withParent((create) => const RoomsRoute()),
          ],
        ),
      ],
      initialRoute: rooms,
      pageFactory: const _NamedSheetFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);
    router.push(room7).ignore();
    await tester.pumpAndSettle();

    router.replace(const CreateRoomRoute()).ignore();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(router.state.routes, const [rooms, CreateRoomRoute()]);
    expect(find.text('Create room'), findsOneWidget);
  });

  testWidgets('replace of the only entry of a tab goes to the route, as '
      'go_router does', (tester) async {
    final router = await pumpTabsApp(tester, rooms);

    await settled(tester, () => router.replace(friends).ignore());

    // As go: the tabs switch, the rooms tab keeps its stack.
    expect(
      router.state.toString(),
      '{RoomsBranch: [RoomsRoute()] | *FriendsBranch: [FriendsRoute()]}',
    );
    expect(find.text('Friends'), findsOneWidget);
  });

  testWidgets('pushReplacement of the only entry of a tab goes to the route '
      'with the routes above it', (tester) async {
    final router = await pumpTabsApp(tester, rooms);

    await settled(tester, () => router.pushReplacement(ann).ignore());

    expect(
      router.state.toString(),
      '{RoomsBranch: [RoomsRoute()] | '
      '*FriendsBranch: [FriendsRoute() > FriendRoute(ann)]}',
    );
    expect(find.text('Friend ann'), findsOneWidget);
  });
}
