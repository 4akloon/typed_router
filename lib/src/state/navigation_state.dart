import 'package:flutter/foundation.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/shell_entry.dart';

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
    : this._(List.unmodifiable(entries), null);

  NavigationState._(this._entries, this.error)
    : routes = List.unmodifiable([for (final entry in _entries) entry.route]) {
    if (_entries.isEmpty) {
      throw StateError('A navigation state needs at least one entry.');
    }
  }

  final List<NavigationEntry> _entries;

  /// What the redirects threw while the router was shown for the first
  /// time or re-checked its stack; `null` otherwise.
  ///
  /// While it is set, the navigator shows only the error screen, and
  /// [routes] keep the stack the redirects failed on. Any successful
  /// navigation clears it. It is an [Object] because a redirect may throw
  /// anything; a loop or a too long chain is a `RedirectChainError`.
  final Object? error;

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

  /// This state with the stack unchanged and [error] set: the redirects
  /// failed on it.
  @internal
  NavigationState withError(Object error) => NavigationState._(_entries, error);

  /// This state without [removed] (a page the navigator popped, or every
  /// page of a shell it popped); this same state when none of them is in
  /// it, or when nothing would be left (a state is never empty).
  @internal
  NavigationState withoutEntries(Iterable<NavigationEntry> removed) {
    final kept = [
      for (final entry in _entries)
        if (!removed.contains(entry)) entry,
    ];
    return kept.length == _entries.length || kept.isEmpty
        ? this
        : NavigationState.fromEntries(kept);
  }

  /// The entries of this state that [other] does not hold, compared by
  /// identity, bottom to top.
  @internal
  List<NavigationEntry> entriesMissingFrom(NavigationState other) =>
      List.unmodifiable([
        for (final entry in _entries)
          if (!other._entries.contains(entry)) entry,
      ]);

  /// Whether [other] holds the same pages (the same stack entries in the
  /// same places) and the same [error]. Two states with equal routes but
  /// rebuilt pages differ.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationState &&
          listEquals(other._entries, _entries) &&
          other.error == error;

  /// Consistent with [==].
  @override
  int get hashCode => Object.hash(Object.hashAll(_entries), error);

  /// `RoomsRoute() > RoomRoute(RoomId(7))`, shell navigators in brackets,
  /// followed by ` (error...)` when the redirects failed; for logs and test
  /// failures.
  @override
  String toString() => switch (error) {
    final error? => '${_describeStack()} (error: $error)',
    null => _describeStack(),
  };

  /// The routes joined with ` > `, each shell navigator in brackets:
  /// `[UsersRoute() > UserRoute(u1)] > ProfileRoute()`.
  String _describeStack() {
    final description = StringBuffer();
    var openShells = const <ShellEntry>[];
    for (final (index, entry) in _entries.indexed) {
      var shared = 0;
      while (shared < openShells.length &&
          shared < entry.shells.length &&
          identical(openShells[shared], entry.shells[shared])) {
        shared++;
      }
      description
        ..write(']' * (openShells.length - shared))
        ..write(index == 0 ? '' : ' > ')
        ..write('[' * (entry.shells.length - shared))
        ..write(entry.route);
      openShells = entry.shells;
    }
    return '$description${']' * openShells.length}';
  }
}
