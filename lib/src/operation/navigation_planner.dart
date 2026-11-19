import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';

/// Which routes may stay on the stack.
typedef RoutePredicate = bool Function(TypedRoute<Object?> route);

/// Plans the candidate state of each stack operation from the current one.
///
/// Changes nothing itself: every method returns a new state, or throws
/// before anything happens when the operation cannot be planned.
final class NavigationPlanner {
  /// Creates a planner over the routes of [_tree].
  NavigationPlanner(this._tree);

  final RouteTree _tree;

  /// The chain of [route] from the tree, keeping the entries of the common
  /// prefix that hold equal routes.
  NavigationState goTo(NavigationState current, TypedRoute<Object?> route) {
    final chain = _tree.chainTo(route);
    final entries = current.entries;
    var keptCount = 0;
    while (keptCount < chain.length &&
        keptCount < entries.length &&
        entries[keptCount].route == chain[keptCount]) {
      keptCount++;
    }
    return NavigationState.fromEntries([
      ...entries.take(keptCount),
      for (final chained in chain.skip(keptCount)) NavigationEntry(chained),
    ]);
  }

  /// [current] with [entry] on top.
  NavigationState pushedOnto(NavigationState current, NavigationEntry entry) {
    _tree.ensurePlaced(entry.route);
    return NavigationState.fromEntries([...current.entries, entry]);
  }

  /// [current] without its top entry; the caller checks there is one below.
  NavigationState withoutTop(NavigationState current) =>
      NavigationState.fromEntries(_belowTop(current));

  /// [current] with [entry] in place of its top entry.
  NavigationState withTopReplaced(
    NavigationState current,
    NavigationEntry entry,
  ) {
    _tree.ensurePlaced(entry.route);
    return NavigationState.fromEntries([..._belowTop(current), entry]);
  }

  /// [current] without the entries above the topmost route that matches
  /// [predicate]. Throws [StateError] when no route matches.
  NavigationState poppedUntil(
    NavigationState current,
    RoutePredicate predicate,
  ) {
    final entries = current.entries;
    final matchIndex = entries.lastIndexWhere(
      (entry) => predicate(entry.route),
    );
    if (matchIndex == -1) {
      throw StateError(
        'No route on the stack matches the predicate; nothing was removed.',
      );
    }
    return NavigationState.fromEntries(entries.take(matchIndex + 1));
  }

  /// [poppedUntil], then [pushedOnto], as one candidate.
  NavigationState pushedAfterPoppingUntil(
    NavigationState current,
    NavigationEntry entry,
    RoutePredicate predicate,
  ) => pushedOnto(poppedUntil(current, predicate), entry);

  Iterable<NavigationEntry> _belowTop(NavigationState current) =>
      current.entries.take(current.entries.length - 1);
}
