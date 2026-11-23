import 'package:typed_navigator/src/operation/branch_switch.dart';
import 'package:typed_navigator/src/operation/entry_chain.dart';
import 'package:typed_navigator/src/operation/go_plan.dart';
import 'package:typed_navigator/src/operation/in_place_update.dart';
import 'package:typed_navigator/src/operation/stack_trim.dart';
import 'package:typed_navigator/src/operation/top_replacement.dart';
import 'package:typed_navigator/src/result/pending_result.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/src/state/typed_router_state.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';

/// Which routes may stay on the stack.
typedef RoutePredicate = bool Function(TypedRoute<Object?> route);

/// Plans the candidate state of each stack operation from the current one.
///
/// Changes nothing itself: every method returns a new state, or throws before
/// anything happens when the operation cannot be planned. New entries get their
/// levels from [EntryChain]; the state keeps the stacks of branches not on
/// screen as the active path changes.
class NavigationPlanner {
  /// Creates a planner over the routes of [_tree] that makes entries with
  /// [_entryChain], plans `go` with [_goPlan] and switches branches with
  /// [_branchSwitch].
  NavigationPlanner(
    this._tree,
    this._entryChain,
    this._goPlan,
    this._branchSwitch,
    InPlaceUpdate inPlaceUpdate,
  ) : _stackTrim = StackTrim(_entryChain),
      _topReplacement = TopReplacement(_entryChain, _goPlan, inPlaceUpdate);

  final RouteTree _tree;
  final EntryChain _entryChain;
  final GoPlan _goPlan;
  final TopReplacement _topReplacement;
  final StackTrim _stackTrim;
  final BranchSwitch _branchSwitch;

  /// The chain of [route] from the tree, as the first state of a router.
  TypedRouterState startingAt(TypedRoute<Object?> route) =>
      TypedRouterState.fromEntries(
        _entryChain.chained(const [], _tree.chainTo(route)),
      );

  /// The chain of [route] from the tree; see [GoPlan].
  TypedRouterState goTo(TypedRouterState current, TypedRoute<Object?> route) =>
      current.showing(_goPlan.entriesFor(current, route));

  /// [current] with [route] on top, in the shell or branch on screen when
  /// it belongs there, else in new ones; [pendingResult] when a push
  /// awaits it.
  TypedRouterState pushedOnto(
    TypedRouterState current,
    TypedRoute<Object?> route, {
    PendingResult<Object?>? pendingResult,
  }) => current.showing([
    ...current.entries,
    _entryChain.entryPushedAbove(
      current.topLevels,
      route,
      pendingResult: pendingResult,
    ),
  ]);

  /// [current] without its top entry; the caller checks there is one below.
  TypedRouterState withoutTop(TypedRouterState current) =>
      current.showing(_belowTop(current));

  /// See [TopReplacement.replaced].
  TypedRouterState withTopReplaced(
    TypedRouterState current,
    TypedRoute<Object?> route, {
    PendingResult<Object?>? pendingResult,
  }) => _topReplacement.replaced(current, route, pendingResult: pendingResult);

  /// See [TopReplacement.updated].
  TypedRouterState withTopUpdated(
    TypedRouterState current,
    TypedRoute<Object?> route, {
    PendingResult<Object?>? pendingResult,
  }) => _topReplacement.updated(current, route, pendingResult: pendingResult);

  /// See [StackTrim.poppedUntil].
  TypedRouterState poppedUntil(
    TypedRouterState current,
    RoutePredicate predicate,
  ) => _stackTrim.poppedUntil(current, predicate);

  /// See [StackTrim.pushedAfterPoppingUntil].
  TypedRouterState pushedAfterPoppingUntil(
    TypedRouterState current,
    TypedRoute<Object?> route,
    RoutePredicate predicate, {
    PendingResult<Object?>? pendingResult,
  }) => _stackTrim.pushedAfterPoppingUntil(
    current,
    route,
    predicate,
    pendingResult: pendingResult,
  );

  /// [current] showing [branchType] of [tabs]: the active branch as it
  /// is, or another one's kept stack or initial chain; [current] itself
  /// when the tabs are not on the active path.
  TypedRouterState branchShown(
    TypedRouterState current,
    TabsEntry tabs,
    Type branchType,
  ) => switch (_branchSwitch.shown(current, tabs, branchType)) {
    final next? => current.showing(next),
    null => current,
  };

  /// [current] showing [branchType] of [tabs] from its initial route.
  TypedRouterState branchReset(
    TypedRouterState current,
    TabsEntry tabs,
    Type branchType,
  ) => switch (_branchSwitch.reset(current, tabs, branchType)) {
    final next? => current.showing(next),
    null => current,
  };

  List<NavigationEntry> _belowTop(TypedRouterState current) =>
      current.entries.take(current.entries.length - 1).toList();
}
