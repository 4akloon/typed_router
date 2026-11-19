import 'package:typed_navigator/src/operation/shell_path.dart';
import 'package:typed_navigator/src/result/pending_result.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_entry.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';

/// Which routes may stay on the stack.
typedef RoutePredicate = bool Function(TypedRoute<Object?> route);

/// Plans the candidate state of each stack operation from the current one.
///
/// Changes nothing itself: every method returns a new state, or throws before
/// anything happens when the operation cannot be planned. New entries get their
/// shell instances from [ShellPath]; a shell no entry stands in any more is
/// gone with it.
final class NavigationPlanner {
  /// Creates a planner over the routes of [_tree].
  NavigationPlanner(this._tree) : _shellPath = ShellPath(_tree);

  final RouteTree _tree;
  final ShellPath _shellPath;

  /// The chain of [route] from the tree, as the first state of a router.
  NavigationState startingAt(TypedRoute<Object?> route) =>
      NavigationState.fromEntries(_chained(const [], _tree.chainTo(route)));

  /// The chain of [route] from the tree, keeping the entries of the common
  /// prefix that hold equal routes, with their shells.
  NavigationState goTo(NavigationState current, TypedRoute<Object?> route) {
    final chain = _tree.chainTo(route);
    final entries = current.entries;
    var keptCount = 0;
    while (keptCount < chain.length &&
        keptCount < entries.length &&
        entries[keptCount].route == chain[keptCount]) {
      keptCount++;
    }
    return NavigationState.fromEntries(
      _chained(entries.take(keptCount).toList(), chain.skip(keptCount)),
    );
  }

  /// [current] with [route] on top, in the shell on screen when it belongs
  /// there; [pendingResult] when a push awaits it.
  NavigationState pushedOnto(
    NavigationState current,
    TypedRoute<Object?> route, {
    PendingResult<Object?>? pendingResult,
  }) => NavigationState.fromEntries([
    ...current.entries,
    _entryAbove(current.entries.last.shells, route, pendingResult),
  ]);

  /// [current] without its top entry; the caller checks there is one below.
  NavigationState withoutTop(NavigationState current) =>
      NavigationState.fromEntries(_belowTop(current));

  /// [current] with [route] in place of its top entry, in the top entry's
  /// shells where they fit.
  NavigationState withTopReplaced(
    NavigationState current,
    TypedRoute<Object?> route, {
    PendingResult<Object?>? pendingResult,
  }) => NavigationState.fromEntries([
    ..._belowTop(current),
    _entryAbove(current.entries.last.shells, route, pendingResult),
  ]);

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
    TypedRoute<Object?> route,
    RoutePredicate predicate, {
    PendingResult<Object?>? pendingResult,
  }) => pushedOnto(
    poppedUntil(current, predicate),
    route,
    pendingResult: pendingResult,
  );

  List<NavigationEntry> _chained(
    List<NavigationEntry> kept,
    Iterable<TypedRoute<Object?>> chain,
  ) {
    final entries = [...kept];
    for (final route in chain) {
      final below = entries.lastOrNull?.shells ?? const <ShellEntry>[];
      entries.add(_entryAbove(below, route, null));
    }
    return entries;
  }

  NavigationEntry _entryAbove(
    List<ShellEntry> below,
    TypedRoute<Object?> route,
    PendingResult<Object?>? pendingResult,
  ) => NavigationEntry(
    route,
    shells: _shellPath.instancesFor(route, below: below),
    pendingResult: pendingResult,
  );

  Iterable<NavigationEntry> _belowTop(NavigationState current) =>
      current.entries.take(current.entries.length - 1);
}
