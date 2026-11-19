import 'package:flutter/foundation.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';

/// What the user sees: the routes on the active path, bottom to top.
///
/// Immutable and never empty. The router creates a new state for every
/// navigation that changes the screen; it has no public constructor.
///
/// Routes pushed imperatively on top of a page (`Navigator.push`,
/// `showDialog`) are not part of the state: [top] stays the page below
/// them.
///
/// ```dart
/// final state = router.state;
/// if (state.contains<AuthArea>() && !session.isSignedIn) { ... }
/// final RoomRoute? room = state.find<RoomRoute>();
/// ```
final class NavigationState {
  /// Creates a state from the entries on the active path, bottom to top.
  ///
  /// Only the router creates states. An empty list is a bug in this
  /// library, so it throws [StateError].
  @internal
  NavigationState.fromEntries(Iterable<NavigationEntry> entries)
    : _entries = List.unmodifiable(entries),
      routes = List.unmodifiable([for (final entry in entries) entry.route]) {
    if (_entries.isEmpty) {
      throw StateError('A navigation state needs at least one entry.');
    }
  }

  final List<NavigationEntry> _entries;

  /// The routes on the active path, from the bottom of the stack to the
  /// top. Unmodifiable.
  final List<TypedRoute<Object?>> routes;

  /// The route on top: the one on screen.
  TypedRoute<Object?> get top => routes.last;

  /// The route of type [R] nearest to the top, or `null` when there is
  /// none. [R] may be a route type or a common supertype of routes.
  R? find<R extends TypedRoute<Object?>>() {
    for (final route in routes.reversed) {
      if (route case final R match) return match;
    }
    return null;
  }

  /// Whether a route on the active path is a [T]: a route type or a marker
  /// interface such as `AuthArea`.
  bool contains<T>() => routes.any((route) => route is T);

  /// The stack entries on the active path, bottom to top. Unmodifiable.
  @internal
  List<NavigationEntry> get entries => _entries;

  /// This state without [entry]; this same state when [entry] is not in it
  /// or is its only entry (a state is never empty).
  @internal
  NavigationState withoutEntry(NavigationEntry entry) =>
      _entries.contains(entry) && _entries.length > 1
      ? NavigationState.fromEntries([
          for (final kept in _entries)
            if (kept != entry) kept,
        ])
      : this;

  /// The entries of this state that [other] does not hold, compared by
  /// identity, bottom to top.
  @internal
  List<NavigationEntry> entriesMissingFrom(NavigationState other) =>
      List.unmodifiable([
        for (final entry in _entries)
          if (!other._entries.contains(entry)) entry,
      ]);

  /// Whether [other] holds the same pages: the same stack entries in the
  /// same places. Two states with equal routes but rebuilt pages differ.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationState && listEquals(other._entries, _entries);

  /// Consistent with [==].
  @override
  int get hashCode => Object.hashAll(_entries);

  /// `RoomsRoute() > RoomRoute(RoomId(7))`, for logs and test failures.
  @override
  String toString() => routes.join(' > ');
}
