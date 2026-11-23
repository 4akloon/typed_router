import 'package:typed_router/src/operation/entry_chain.dart';
import 'package:typed_router/src/operation/go_plan.dart';
import 'package:typed_router/src/operation/in_place_update.dart';
import 'package:typed_router/src/result/pending_result.dart';
import 'package:typed_router/src/route/typed_route.dart';
import 'package:typed_router/src/state/navigation_entry.dart';
import 'package:typed_router/src/state/typed_router_state.dart';

/// Plans `pushReplacement` and `replace`: a route in place of the top entry,
/// pushed onto the entry below, as go_router's; with nothing below, the route
/// and the routes above it, as `go`.
class TopReplacement {
  /// Creates the plans: new entries from [_entryChain], `go` from
  /// [_goPlan], pages updated in place where [_inPlaceUpdate] says so.
  TopReplacement(this._entryChain, this._goPlan, this._inPlaceUpdate);

  final EntryChain _entryChain;
  final GoPlan _goPlan;
  final InPlaceUpdate _inPlaceUpdate;

  /// [current] with [route] in a new page in place of its top entry;
  /// [pendingResult] awaits it.
  TypedRouterState replaced(
    TypedRouterState current,
    TypedRoute<Object?> route, {
    PendingResult<Object?>? pendingResult,
  }) {
    final below = _belowTop(current);
    if (below.isEmpty) {
      final went = current.showing(_goPlan.entriesFor(current, route));
      final top = went.entries.last;
      return went.showing([
        ..._belowTop(went),
        NavigationEntry(
          top.route,
          levels: top.levels,
          pendingResult: pendingResult,
        ),
      ]);
    }
    return current.showing([
      ...below,
      _entryChain.entryPushedAbove(
        below.last.levels,
        route,
        pendingResult: pendingResult,
      ),
    ]);
  }

  /// [current] with [route] shown in the top entry's page where that page
  /// can show it; else as [replaced]. With nothing below, as `go`.
  TypedRouterState updated(
    TypedRouterState current,
    TypedRoute<Object?> route, {
    PendingResult<Object?>? pendingResult,
  }) {
    final replacement = replaced(current, route, pendingResult: pendingResult);
    final below = _belowTop(current);
    if (below.isEmpty) return replacement;
    return switch (_inPlaceUpdate.of(
      current.entries.last,
      replacement.entries.last,
    )) {
      final inPlace? => current.showing([...below, inPlace]),
      null => replacement,
    };
  }

  List<NavigationEntry> _belowTop(TypedRouterState current) =>
      current.entries.take(current.entries.length - 1).toList();
}
