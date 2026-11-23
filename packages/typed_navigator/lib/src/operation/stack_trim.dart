import 'package:typed_navigator/src/operation/entry_chain.dart';
import 'package:typed_navigator/src/operation/navigation_planner.dart';
import 'package:typed_navigator/src/result/pending_result.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/typed_router_state.dart';

/// Plans the operations that remove entries down to a route a predicate holds
/// for: `popUntil` and `pushAndRemoveUntil`.
class StackTrim {
  /// Creates the plans; new entries get their levels from [_entryChain].
  StackTrim(this._entryChain);

  final EntryChain _entryChain;

  /// [current] without the entries above the topmost route that matches
  /// [predicate]. Throws [StateError] when no route matches: the navigator
  /// would be left empty.
  TypedRouterState poppedUntil(
    TypedRouterState current,
    RoutePredicate predicate,
  ) => switch (_keptUntil(current, predicate)) {
    [] => throw StateError(
      'No route on the stack matches the predicate; nothing was removed.',
    ),
    final kept => current.showing(kept),
  };

  /// The entries up to the topmost route that matches [predicate], then a new
  /// entry for [route] above them; [route] alone, in its own levels, when none
  /// matches, as `Navigator.pushAndRemoveUntil`.
  TypedRouterState pushedAfterPoppingUntil(
    TypedRouterState current,
    TypedRoute<Object?> route,
    RoutePredicate predicate, {
    PendingResult<Object?>? pendingResult,
  }) {
    final kept = _keptUntil(current, predicate);
    return current.showing([
      ...kept,
      _entryChain.entryPushedAbove(
        kept.lastOrNull?.levels ?? const [],
        route,
        pendingResult: pendingResult,
      ),
    ]);
  }

  List<NavigationEntry> _keptUntil(
    TypedRouterState current,
    RoutePredicate predicate,
  ) {
    final entries = current.entries;
    final matchIndex = entries.lastIndexWhere(
      (entry) => predicate(entry.route),
    );
    return entries.take(matchIndex + 1).toList();
  }
}
