import 'package:flutter/foundation.dart';

/// A place in the app the user can navigate to, described as a value.
///
/// Extend it once per screen (or per screen state) and list every field
/// that identifies the route in [fields]. Two routes are equal when they
/// have the same type and equal [fields]; the router keeps a page alive
/// while an equal route stays in the same place, and builds a new page
/// otherwise.
///
/// [T] is the type of the value the route returns when it is popped:
/// `router.push(const EditNoteRoute())` is a `Future<String?>` for
/// `EditNoteRoute extends TypedRoute<String>`. Use `TypedRoute<void>` for
/// routes that return nothing.
///
/// A route is plain data. How it is shown, guarded or encoded in a URL is
/// declared on its node in the route tree, not here. Marker interfaces
/// (`implements AuthArea`) are welcome: they describe what the route is.
///
/// ```dart
/// class RoomRoute extends TypedRoute<void> {
///   const RoomRoute(this.id);
///
///   final RoomId id;
///
///   @override
///   List<Object?> get fields => [id];
/// }
///
/// class RoomsRoute extends TypedRoute<void> {
///   const RoomsRoute();
///
///   @override
///   List<Object?> get fields => const [];
/// }
/// ```
///
/// A class may `implement` [TypedRoute] instead of extending it. It must
/// then implement `==` and `hashCode` with value semantics itself.
abstract class TypedRoute<T> {
  /// Creates a route. Subclasses should keep a `const` constructor.
  const TypedRoute();

  /// The values that identify this route, in a fixed order.
  ///
  /// Every element must have value equality itself (ids, enums, strings,
  /// other routes, immutable values). A mutable `List` compares by
  /// identity: wrap collections in a value type.
  List<Object?> get fields;

  /// Whether [other] is a route of the same type with equal [fields].
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          other is TypedRoute<Object?> &&
          listEquals(other.fields, fields);

  /// Combines the type and [fields], consistent with [==].
  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(fields));

  /// `RoomRoute(RoomId(7))`: the type and [fields], for debugging only.
  ///
  /// Type names are minified on the web and obfuscated in release builds;
  /// anything stable (analytics, error reports) uses the node's name.
  @override
  String toString() =>
      // Debug output only, as documented above.
      // ignore: avoid_type_to_string
      '$runtimeType(${fields.join(', ')})';
}
