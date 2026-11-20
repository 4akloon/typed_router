import 'package:typed_navigator/src/operation/branch_switch.dart';
import 'package:typed_navigator/src/operation/entry_chain.dart';
import 'package:typed_navigator/src/operation/go_plan.dart';
import 'package:typed_navigator/src/result/pending_result.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';

/// Which routes may stay on the stack.
typedef RoutePredicate = bool Function(TypedRoute<Object?> route);

/// Plans the candidate state of each stack operation from the current one.
///
/// Changes nothing itself: every method returns a new state, or throws before
/// anything happens when the operation cannot be planned. New entries get their
/// levels from [EntryChain]; the state keeps the stacks of branches not on
/// screen as the active path changes.
final class NavigationPlanner {
  /// Creates a planner over the routes of [_tree] that makes entries with
  /// [_entryChain], plans `go` with [_goPlan] and switches branches with
  /// [_branchSwitch].
  NavigationPlanner(
    this._tree,
    this._entryChain,
    this._goPlan,
    this._branchSwitch,
  );

  final RouteTree _tree;
  final EntryChain _entryChain;
  final GoPlan _goPlan;
  final BranchSwitch _branchSwitch;

  /// The chain of [route] from the tree, as the first state of a router.
  NavigationState startingAt(TypedRoute<Object?> route) =>
      NavigationState.fromEntries(
        _entryChain.chained(const [], _tree.chainTo(route)),
      );

  /// The chain of [route] from the tree; see [GoPlan].
  NavigationState goTo(NavigationState current, TypedRoute<Object?> route) =>
      current.showing(_goPlan.entriesFor(current, route));

  /// [current] with [route] on top, in the shell or branch on screen when
  /// it belongs there, else in new ones; [pendingResult] when a push
  /// awaits it.
  NavigationState pushedOnto(
    NavigationState current,
    TypedRoute<Object?> route, {
    PendingResult<Object?>? pendingResult,
  }) => current.showing([
    ...current.entries,
    _entryChain.entryAbove(
      current.topLevels,
      route,
      pendingResult: pendingResult,
    ),
  ]);

  /// [current] without its top entry; the caller checks there is one below.
  NavigationState withoutTop(NavigationState current) =>
      current.showing(_belowTop(current));

  /// [current] with [route] in place of its top entry, in the top entry's
  /// levels where they fit.
  NavigationState withTopReplaced(
    NavigationState current,
    TypedRoute<Object?> route, {
    PendingResult<Object?>? pendingResult,
  }) => current.showing([
    ..._belowTop(current),
    _entryChain.entryAbove(
      current.topLevels,
      route,
      pendingResult: pendingResult,
    ),
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
    return current.showing(entries.take(matchIndex + 1).toList());
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

  /// [current] showing [branchType] of [tabs]: the active branch as it
  /// is, or another one's kept stack or initial chain; [current] itself
  /// when the tabs are not on the active path.
  NavigationState branchShown(
    NavigationState current,
    TabsEntry tabs,
    Type branchType,
  ) => switch (_branchSwitch.shown(current, tabs, branchType)) {
    final next? => current.showing(next),
    null => current,
  };

  /// [current] showing [branchType] of [tabs] from its initial route.
  NavigationState branchReset(
    NavigationState current,
    TabsEntry tabs,
    Type branchType,
  ) => switch (_branchSwitch.reset(current, tabs, branchType)) {
    final next? => current.showing(next),
    null => current,
  };

  List<NavigationEntry> _belowTop(NavigationState current) =>
      current.entries.take(current.entries.length - 1).toList();
}
