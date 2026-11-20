import 'package:typed_navigator/src/operation/entry_chain.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';

/// Plans `go`: the chain of the route from the tree, keeping what it can.
///
/// Entries of the common prefix that hold equal routes stay, compared with
/// the active path or, for a route of another branch, with the entries
/// below the tabs followed by that branch's kept stack. New entries reuse
/// the shells and tabs of the entries they replace, wherever those stand
/// on the active path.
final class GoPlan {
  /// Creates the plan over routes of [_tree], making entries with
  /// [_entryChain].
  GoPlan(this._tree, this._entryChain);

  final RouteTree _tree;
  final EntryChain _entryChain;

  /// The active path `go(route)` leads to from [current].
  List<NavigationEntry> entriesFor(
    NavigationState current,
    TypedRoute<Object?> route,
  ) {
    final chain = _tree.chainTo(route);
    return entriesFrom(current, _closestBase(current, chain), chain);
  }

  /// The active path showing [chain] from [base], a stack [current] holds
  /// (its active path, or the entries below a tabs instance followed by a
  /// branch's stack): the entries of [base] that hold the routes [chain]
  /// starts with stay; new entries for the rest reuse the shells and tabs
  /// of the entries they replace.
  List<NavigationEntry> entriesFrom(
    NavigationState current,
    List<NavigationEntry> base,
    List<TypedRoute<Object?>> chain,
  ) {
    final kept = base.take(_commonPrefix(base, chain)).toList();
    return _entryChain.chained(
      kept,
      chain.skip(kept.length),
      replaceable: [
        for (final entry in [...current.entries, ...base])
          if (!kept.contains(entry)) entry.levels,
      ],
    );
  }

  /// The stack [chain] is compared with: the active path, or the entries
  /// below a tabs instance followed by one of its kept branch stacks, the
  /// one sharing the longest prefix with [chain].
  List<NavigationEntry> _closestBase(
    NavigationState current,
    List<TypedRoute<Object?>> chain,
  ) {
    var closest = current.entries;
    var closestLength = _commonPrefix(closest, chain);
    final shownTabs = {
      for (final entry in current.entries)
        for (final branch in entry.branches) branch.tabs,
    };
    for (final tabs in shownTabs) {
      final firstIn = current.entries.indexWhere(
        (entry) => entry.standsIn(tabs),
      );
      for (final stack in current.inactiveBranches.stacksOf(tabs)) {
        final base = [...current.entries.take(firstIn), ...stack];
        final length = _commonPrefix(base, chain);
        if (length > closestLength) (closest, closestLength) = (base, length);
      }
    }
    return closest;
  }

  int _commonPrefix(
    List<NavigationEntry> entries,
    List<TypedRoute<Object?>> chain,
  ) {
    var length = 0;
    while (length < chain.length &&
        length < entries.length &&
        entries[length].route == chain[length]) {
      length++;
    }
    return length;
  }
}
