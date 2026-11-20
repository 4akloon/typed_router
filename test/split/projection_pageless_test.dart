// Pageless routes of the navigators a change of projection removes complete
// with null.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/operation_fixtures.dart' show ResultProbe;
import '../support/split_fixtures.dart';

PageRouteBuilder<String> _sheet() => PageRouteBuilder<String>(
  opaque: false,
  pageBuilder: (context, _, _) => const Text('Sheet'),
);

void main() {
  testWidgets('a pageless route of a column completes with null when the '
      'split becomes a stack', (tester) async {
    final router = await pumpSplitApp(tester, room1);
    final sheet = ResultProbe(navigatorOf(tester, 'Room 1').push(_sheet()));
    await tester.pumpAndSettle();

    await resizeWindow(tester, 400);

    expect(sheet.completions, [null]);
    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
    expect(find.text('Sheet'), findsNothing);
  });

  testWidgets('a pageless route of the stack completes with null when the '
      'split becomes columns', (tester) async {
    final router = await pumpSplitApp(tester, room1, width: 400);
    final sheet = ResultProbe(navigatorOf(tester, 'Room 1').push(_sheet()));
    await tester.pumpAndSettle();

    await resizeWindow(tester, 1000);

    expect(sheet.completions, [null]);
    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
    expect(find.text('Room 1:0'), findsOneWidget);
  });

  testWidgets('crossing the threshold without pageless routes recreates no '
      'screen', (tester) async {
    final log = ScreenLog();
    await pumpSplitApp(tester, room1, log: log);

    await resizeWindow(tester, 400);
    await resizeWindow(tester, 1000);

    expect(log.created, ['Rooms', 'Room 1']);
  });
}
