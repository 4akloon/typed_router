// Replace updates the top page in place, as go_router's; pushReplacement shows
// a new page, as Navigator's.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/shell_fixtures.dart';

/// A room screen with state of its own, so a test sees whether it survives.
class _RoomScreen extends StatefulWidget {
  const _RoomScreen(this.room);

  final RoomRoute room;

  @override
  State<_RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<_RoomScreen> {
  @override
  Widget build(BuildContext context) => Text('Room ${widget.room.id.value}');
}

Future<TypedRouter> _pumpRoom(WidgetTester tester) async {
  final router = TypedRouter(
    routes: [
      RouteNode<RoomsRoute>(
        build: (context, rooms) => const Text('Rooms'),
        children: [
          RouteNode<RoomRoute>(
            build: (context, room) => _RoomScreen(room),
          ).withParent((room) => const RoomsRoute()),
          const RouteNode<CreateRoomRoute>(
            build: _createRoom,
            pageFactory: SheetPageFactory(),
          ).withParent((createRoom) => const RoomsRoute()),
        ],
      ),
    ],
    initialRoute: rooms,
    pageFactory: const TestPageFactory(),
  );
  addTearDown(router.dispose);
  await pumpWidgetsRouter(tester, router);
  return router;
}

Widget _createRoom(BuildContext context, CreateRoomRoute route) =>
    const Text('Create room');

const _room8 = RoomRoute(RoomId(8));

void main() {
  testWidgets('replace updates the top page in place and keeps its screen', (
    tester,
  ) async {
    final router = await _pumpRoom(tester);
    final room7 = ResultProbe(router.push(const RoomRoute(RoomId(7))));
    await tester.pumpAndSettle();
    final screen = tester.state(find.byType(_RoomScreen));

    router.replace(_room8).ignore();
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
    expect(router.state.routes, const [rooms, _room8]);
    expect(find.text('Room 8'), findsOneWidget);
    expect(tester.state(find.byType(_RoomScreen)), same(screen));
    expect(room7.completions, [null]);
  });

  testWidgets('replace with a route that gets another kind of page shows a '
      'new page', (tester) async {
    final router = await _pumpRoom(tester);
    final room7 = ResultProbe(router.push(const RoomRoute(RoomId(7))));
    await tester.pumpAndSettle();

    router.replace(const CreateRoomRoute()).ignore();
    await tester.pumpAndSettle();

    expect(router.state.routes, const [rooms, CreateRoomRoute()]);
    expect(find.text('Create room'), findsOneWidget);
    expect(find.byType(_RoomScreen), findsNothing);
    expect(room7.completions, [null]);
  });

  testWidgets('pushReplacement shows a new page with a transition', (
    tester,
  ) async {
    final router = await _pumpRoom(tester);
    final room7 = ResultProbe(router.push(const RoomRoute(RoomId(7))));
    await tester.pumpAndSettle();
    final screen = tester.state(find.byType(_RoomScreen));

    router.pushReplacement(_room8).ignore();
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpAndSettle();

    expect(router.state.routes, const [rooms, _room8]);
    expect(find.text('Room 8'), findsOneWidget);
    expect(tester.state(find.byType(_RoomScreen)), isNot(same(screen)));
    expect(room7.completions, [null]);
  });

  testWidgets('replace with a route in another level shows a new page', (
    tester,
  ) async {
    final router = await pumpShellApp(tester, account);

    router.replace(users).ignore();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(router.state.toString(), '[UsersRoute()]');
    expect(find.text('Users'), findsOneWidget);
  });
}
