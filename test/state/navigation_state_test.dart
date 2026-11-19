// The navigation state. Builds states through the internal constructor on
// purpose, to test the state apart from the router.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/route_fixtures.dart';
import '../support/state_fixtures.dart';

const rooms = RoomsRoute();
const room7 = RoomRoute(RoomId(7));

void main() {
  group('queries', () {
    test('routes lists the active path from bottom to top', () {
      expect(stateOf([rooms, room7]).routes, [rooms, room7]);
    });

    test('routes cannot be modified', () {
      final routes = stateOf([rooms]).routes;

      expect(() => routes.add(room7), throwsUnsupportedError);
    });

    test('top is the last route', () {
      expect(stateOf([rooms, room7]).top, room7);
    });

    test('find returns the route of the type nearest to the top', () {
      const room8 = RoomRoute(RoomId(8));

      expect(stateOf([room7, rooms, room8]).find<RoomRoute>(), room8);
    });

    test('find returns null when no route has the type', () {
      expect(stateOf([rooms]).find<RoomRoute>(), isNull);
    });

    test('find accepts a common supertype of routes', () {
      const featured = FeaturedRoomRoute(RoomId(9));

      expect(stateOf([room7, featured]).find<RoomRoute>(), featured);
      expect(stateOf([room7]).find<TypedRoute<void>>(), room7);
    });

    test('contains is true for a route type on the path', () {
      expect(stateOf([rooms, room7]).contains<RoomsRoute>(), isTrue);
    });

    test('contains is true for a marker a route implements', () {
      expect(
        stateOf([rooms, const AccountRoute()]).contains<AuthArea>(),
        isTrue,
      );
    });

    test('contains is false otherwise', () {
      final state = stateOf([rooms, room7]);

      expect(state.contains<AuthArea>(), isFalse);
      expect(state.contains<AccountRoute>(), isFalse);
    });
  });

  group('equality', () {
    test('states with the same entries are equal and share a hash', () {
      final entries = [NavigationEntry(rooms), NavigationEntry(room7)];
      final first = NavigationState.fromEntries(entries);
      final second = NavigationState.fromEntries(entries);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('states with equal routes but different entries are not equal', () {
      expect(stateOf([rooms, room7]), isNot(stateOf([rooms, room7])));
    });
  });

  test('toString joins the routes with an arrow', () {
    expect(
      stateOf([rooms, room7]).toString(),
      'RoomsRoute() > RoomRoute(RoomId(7))',
    );
  });

  test('a state without entries cannot be created', () {
    expect(() => NavigationState.fromEntries(const []), throwsStateError);
  });
}
