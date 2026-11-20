// Every branch navigator of tabs has a hero controller of its own.

import 'package:flutter_test/flutter_test.dart';

import '../support/hero_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/tabs_fixtures.dart';

void main() {
  testWidgets("a hero flies between two pages of a branch's navigator", (
    tester,
  ) async {
    final router = await pumpMaterialHeroes(
      tester,
      heroTabsRoutes(),
      const RoomsRoute(),
    );

    await pushHalfway(tester, router, const RoomRoute(RoomId(7)));

    expect(isInFlight('room'), isTrue);
  });

  testWidgets('heroes fly in each visited branch with a controller of its '
      'own', (tester) async {
    final router = await pumpMaterialHeroes(
      tester,
      heroTabsRoutes(),
      const RoomsRoute(),
    );
    await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());

    await pushHalfway(tester, router, ann);
    expect(isInFlight('friend'), isTrue);
    await tester.pumpAndSettle();

    await settled(tester, () => shellOf(tester).goBranch<RoomsBranch>());
    await pushHalfway(tester, router, const RoomRoute(RoomId(7)));
    expect(isInFlight('room'), isTrue);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      heroControllerOf(tester, 'room'),
      isNot(same(heroControllerOf(tester, 'friend'))),
    );
  });
}
