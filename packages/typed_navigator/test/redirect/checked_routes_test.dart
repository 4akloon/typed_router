// Which routes an operation checks.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/redirect_fixtures.dart';
import '../support/route_fixtures.dart';

Future<TypedRouter> _pumpSession(
  WidgetTester tester,
  Session session, {
  List<String>? calls,
}) async {
  final router = sessionRouter(session, calls: calls);
  await pumpWidgetsRouter(tester, router);
  return router;
}

void main() {
  testWidgets('a node redirect guards a descendant pushed without its '
      'ancestors', (tester) async {
    final calls = <String>[];
    final router = await _pumpSession(
      tester,
      Session(isSignedIn: true),
      calls: calls,
    );
    calls.clear();

    router.push(room7).ignore();
    expect(calls, [
      'router: RoomRoute(RoomId(7))',
      'Rooms node: RoomsRoute() for RoomRoute(RoomId(7))',
      'Room node: RoomRoute(RoomId(7)) for RoomRoute(RoomId(7))',
    ]);
    calls.clear();

    router.push(editNote).ignore();
    expect(calls, ['router: EditNoteRoute()']);
    await tester.pumpAndSettle();
    expect(find.text('Edit note'), findsOneWidget);
  });

  testWidgets('operations do not re-check routes already on the stack', (
    tester,
  ) async {
    final calls = <String>[];
    final router = await _pumpSession(
      tester,
      Session(isSignedIn: true),
      calls: calls,
    );
    router.go(room7);
    calls.clear();

    router.push(const AccountRoute()).ignore();

    expect(calls, ['router: AccountRoute()']);
    expect(router.state.routes, const [rooms, room7, AccountRoute()]);
    await tester.pumpAndSettle();
    expect(find.text('Account'), findsOneWidget);
  });
}
