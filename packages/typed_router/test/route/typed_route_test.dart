// A route as a value: equality, hash code and description.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import '../support/route_fixtures.dart';

// Built from variables so the instances are not canonicalised `const`
// objects: equality must come from the fields, not from identity.
RoomRoute room(int id) => RoomRoute(RoomId(id));
FeaturedRoomRoute featuredRoom(int id) => FeaturedRoomRoute(RoomId(id));
ProfileRoute profile(String userId, String tab) => ProfileRoute(userId, tab);
SearchRoute search(String tag) => SearchRoute([tag]);

void main() {
  group('equality', () {
    test('routes of one type with equal fields are equal and share a hash', () {
      expect(room(7), room(7));
      expect(room(7).hashCode, room(7).hashCode);
    });

    test('a constructor tear-off builds equal routes', () {
      const RoomsRoute Function() createRooms = RoomsRoute.new;

      expect(createRooms(), createRooms());
      expect(createRooms().hashCode, createRooms().hashCode);
    });

    test('routes of one type with different fields are not equal', () {
      expect(room(7), isNot(room(8)));
    });

    test('routes of different types with the same fields are not equal', () {
      final featured = featuredRoom(7);

      expect(featured, isNot(room(7)));
      expect(room(7), isNot(featured));
    });

    test('field-less routes of one type are equal', () {
      const RoomsRoute Function() createRooms = RoomsRoute.new;

      expect(const RoomsRoute(), createRooms());
    });

    test('a route equals itself and no value of another type', () {
      final route = room(7);

      expect(route, route);
      const Object unrelated = 7;

      expect(route == unrelated, isFalse);
      expect(route == const RoomsRoute(), isFalse);
    });

    test('the order of fields matters', () {
      expect(profile('u1', 'details'), isNot(profile('details', 'u1')));
    });

    test('a mutable list among the fields compares by identity', () {
      final tags = ['news'];

      expect(SearchRoute(tags), SearchRoute(tags));
      expect(search('news'), isNot(search('news')));
    });
  });

  group('description', () {
    test('toString shows the type and the fields', () {
      expect(room(7).toString(), 'RoomRoute(RoomId(7))');
      expect(const RoomsRoute().toString(), 'RoomsRoute()');
      expect(profile('u1', 'details').toString(), 'ProfileRoute(u1, details)');
    });
  });

  group('implementing instead of extending', () {
    test('uses the route\'s own equality, hash and description', () {
      const lower = CaseInsensitiveRoute('lobby');
      const upper = CaseInsensitiveRoute('LOBBY');

      expect(lower, upper);
      expect(lower.hashCode, upper.hashCode);
      expect(lower.toString(), 'CaseInsensitive(lobby)');
    });
  });

  group('result type', () {
    test('is part of the route type', () {
      const route = EditNoteRoute();

      expect(route, isA<TypedRoute<String>>());
      expect(route, isNot(isA<TypedRoute<int>>()));
    });
  });
}
