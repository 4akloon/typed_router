import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/router/navigation_state_scope.dart';
import 'package:typed_navigator/src/state/inactive_branches.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/route_lookup.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/src/state/stack_description.dart';

/// What the user sees: the routes on the active path, bottom to top.
///
/// Immutable and never empty. The router creates a new state for every
/// navigation that changes the screen; it has no public constructor.
///
/// Routes pushed imperatively over a page (`Navigator.push`, `showDialog`)
/// are not in the state: [top] stays the page below them.
///
/// ```dart
/// final state = router.state;
/// if (state.contains<AuthArea>() && !session.isSignedIn) { ... }
/// final RoomRoute? room = state.find<RoomRoute>();
/// ```
class NavigationState {
  /// Creates a state from the entries on the active path, bottom to top.
  ///
  /// Only the router creates states. An empty list is a bug in this
  /// library, so it throws [StateError].
  @internal
  NavigationState.fromEntries(Iterable<NavigationEntry> entries)
    : this._(List.unmodifiable(entries), null, const InactiveBranches.none());

  NavigationState._(this._entries, this.error, this._inactive)
    : routes = List.unmodifiable([for (final entry in _entries) entry.route]) {
    if (_entries.isEmpty) {
      throw StateError('A navigation state needs at least one entry.');
    }
  }

  /// The state of the router above [context], which rebuilds on every
  /// navigation, as with `ModalRoute.of`: for a screen showing the state, a
  /// list highlighting the item opened from it. Throws [FlutterError] without a
  /// router above.
  static NavigationState of(BuildContext context) =>
      NavigationStateScope.stateOf(context);

  final List<NavigationEntry> _entries;
  final InactiveBranches _inactive;

  /// What the redirects threw when the router was first shown or re-checked
  /// its stack, else `null`. While set, only the error screen shows and
  /// [routes] keep the failed stack; a successful navigation clears it. An
  /// [Object]: a redirect may throw anything (a loop: `RedirectChainError`).
  final Object? error;

  /// The routes on the active path, bottom to top. Unmodifiable.
  final List<TypedRoute<Object?>> routes;

  /// The route on top: the one on screen.
  TypedRoute<Object?> get top => routes.last;

  /// The route of type [R] (a route type or a common supertype) nearest to
  /// the top, or `null`.
  R? find<R extends TypedRoute<Object?>>() => RouteLookup(routes).find<R>();

  /// Whether a route on the active path is a [T]: a route type or a marker
  /// interface such as `AuthArea`.
  bool contains<T>() => RouteLookup(routes).contains<T>();

  /// The route right above [route]'s entry nearest to the top (as [find]):
  /// the item a list opened, seen under a back gesture; else `null`.
  TypedRoute<Object?>? routeAfter(TypedRoute<Object?> route) =>
      RouteLookup(routes).after(route);

  /// The stack entries on the active path, bottom to top.
  @internal
  List<NavigationEntry> get entries => _entries;

  /// The kept stacks of the branches not on screen.
  @internal
  InactiveBranches get inactiveBranches => _inactive;

  /// The levels of navigators the top page stands in, outer first.
  @internal
  List<ShellLevel> get topLevels => _entries.last.levels;

  /// Every entry: the active path, then the kept branch stacks.
  @internal
  List<NavigationEntry> get allEntries => [..._entries, ..._inactive.entries];

  /// The state with [next] on screen: the kept branch stacks follow the change
  /// of active branches.
  @internal
  NavigationState showing(List<NavigationEntry> next) => NavigationState._(
    List.unmodifiable(next),
    null,
    _inactive.afterShowing(_entries, next),
  );

  /// This state with [error] set: the redirects failed on its stack.
  @internal
  NavigationState withError(Object error) =>
      NavigationState._(_entries, error, _inactive);

  /// This state without its error: the stack the redirects failed on.
  @internal
  NavigationState withoutError() =>
      NavigationState._(_entries, null, _inactive);

  /// This state without [removed] (pages a navigator popped by itself, on
  /// screen or in a hidden branch); this same state when nothing changes
  /// or nothing would be left on screen.
  @internal
  NavigationState withoutEntries(Iterable<NavigationEntry> removed) {
    final removedEntries = removed.toSet();
    final kept = [
      ..._entries.where((entry) => !removedEntries.contains(entry)),
    ];
    if (kept.isEmpty) return this;
    final next = NavigationState._(
      List.unmodifiable(kept),
      error,
      _inactive.without(removedEntries).afterShowing(_entries, kept),
    );
    return next == this ? this : next;
  }

  /// Whether [other] holds the same pages (entries on screen and kept) and
  /// [error]. Two states with equal routes but rebuilt pages differ, and
  /// an app's own implementation equals no state of the router.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          other is NavigationState &&
          listEquals(other._entries, _entries) &&
          other._inactive == _inactive &&
          other.error == error;

  /// Consistent with [==].
  @override
  int get hashCode => Object.hash(Object.hashAll(_entries), _inactive, error);

  /// `RoomsRoute() > RoomRoute(RoomId(7))`, a shell's navigator in brackets,
  /// tabs in braces with their branches, followed by ` (error...)` when the
  /// redirects failed; for logs and test failures.
  @override
  String toString() => switch ((StackDescription(_entries, _inactive), error)) {
    (final stack, final error?) => '$stack (error: $error)',
    (final stack, null) => '$stack',
  };
}
