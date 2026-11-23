// Sample routes for tests, shaped like a chat app's.

import 'package:typed_router/typed_router.dart';

/// A room id with value equality.
class RoomId {
  const RoomId(this.value);

  final int value;

  @override
  bool operator ==(Object other) => other is RoomId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'RoomId($value)';
}

/// A route with one field.
class RoomRoute extends TypedRoute<void> {
  const RoomRoute(this.id);

  final RoomId id;

  @override
  List<Object?> get fields => [id];
}

/// A subtype with the same fields as [RoomRoute].
class FeaturedRoomRoute extends RoomRoute {
  const FeaturedRoomRoute(super.id);
}

/// A route without fields.
class RoomsRoute extends TypedRoute<void> {
  const RoomsRoute();

  @override
  List<Object?> get fields => const [];
}

/// A route with two fields of the same type, where the order matters.
class ProfileRoute extends TypedRoute<void> {
  const ProfileRoute(this.userId, this.tab);

  final String userId;
  final String tab;

  @override
  List<Object?> get fields => [userId, tab];
}

/// A route that keeps a mutable list among its fields.
class SearchRoute extends TypedRoute<void> {
  const SearchRoute(this.tags);

  final List<String> tags;

  @override
  List<Object?> get fields => [tags];
}

/// A route that returns the edited text.
class EditNoteRoute extends TypedRoute<String> {
  const EditNoteRoute();

  @override
  List<Object?> get fields => const [];
}

/// A route that implements [TypedRoute] with its own, case-insensitive
/// equality instead of extending it.
class CaseInsensitiveRoute implements TypedRoute<void> {
  const CaseInsensitiveRoute(this.key);

  final String key;

  @override
  List<Object?> get fields => [key];

  @override
  bool operator ==(Object other) =>
      other is CaseInsensitiveRoute &&
      other.key.toLowerCase() == key.toLowerCase();

  @override
  int get hashCode => key.toLowerCase().hashCode;

  @override
  String toString() => 'CaseInsensitive($key)';
}

/// A marker interface for routes that need a signed-in user.
abstract interface class AuthArea {}

/// A route behind authentication, marked with [AuthArea].
class AccountRoute extends TypedRoute<void> implements AuthArea {
  const AccountRoute();

  @override
  List<Object?> get fields => const [];
}
