// The redirects of tabs guard routes placed above them, as the tree places them
// under the tabs.

import 'package:flutter_test/flutter_test.dart';

import '../support/app_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/slots_fixtures.dart';
import '../support/tabs_fixtures.dart';

void main() {
  testWidgets('tab redirects guard routes placed above the tabs', (
    tester,
  ) async {
    final calls = <String>[];
    var isBlocked = false;
    final router = await pumpSlotsApp(
      tester,
      calls: calls,
      isPlacedBlocked: () => isBlocked,
    );
    isBlocked = true;
    calls.clear();

    await settled(tester, () => router.push(const CreateRoomRoute()).ignore());
    expect(calls.first, 'tabs: CreateRoomRoute()');
    expect(router.state.top, isNot(isA<CreateRoomRoute>()));

    calls.clear();
    const profile = ProfileRoute('u1', 'games');
    await settled(tester, () => router.push(profile).ignore());
    expect(calls.first, 'tabs: ProfileRoute(u1, games)');
    expect(router.state.top, isNot(profile));
    expect(find.text('Friends'), findsOneWidget);
  });
}
