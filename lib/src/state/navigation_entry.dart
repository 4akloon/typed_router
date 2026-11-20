import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/result/pending_result.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/shell_level.dart';

/// One page on a stack: a route together with the identity of its page,
/// and the push waiting for its result, if any.
///
/// Entries are compared by identity, not by value. Two entries holding
/// equal routes are different pages: when the router builds a new entry
/// for an equal route, the page is built again. That is why this class
/// does not override `==`.
///
/// Internal: not exported.
final class NavigationEntry {
  /// Creates an entry for [route] inside [levels] (outer first);
  /// `pendingResult` when a push awaits it.
  NavigationEntry(
    this.route, {
    List<ShellLevel> levels = const [],
    this._pendingResult,
  }) : levels = List.unmodifiable(levels);

  /// The route shown by this page.
  final TypedRoute<Object?> route;

  /// Keys the screen of this page, so the page of a level can ask how the route
  /// on top answers a pop.
  final GlobalKey screenKey = GlobalKey();

  /// The levels of navigators this page stands in (shell instances, branches of
  /// tabs), from the outer one in; empty for a page of the root navigator.
  final List<ShellLevel> levels;

  /// The branches of tabs this page stands in, from the outer one in.
  Iterable<BranchEntry> get branches => levels.whereType<BranchEntry>();

  /// Whether this page stands in [level].
  bool isIn(ShellLevel level) => levels.contains(level);

  /// The branch of [tabs] this page stands in, or `null`.
  BranchEntry? branchOf(TabsEntry tabs) =>
      branches.where((branch) => identical(branch.tabs, tabs)).firstOrNull;

  /// Whether this page stands in a branch of [tabs].
  bool standsIn(TabsEntry tabs) => branchOf(tabs) != null;

  /// This page's levels outside [tabs], then [branchType] of [tabs]: where
  /// a page of that branch stands.
  List<ShellLevel> levelsIn(TabsEntry tabs, Type branchType) {
    final current = branchOf(tabs);
    return [
      ...levels.takeWhile((level) => level != current),
      tabs.branch(branchType),
    ];
  }

  final PendingResult<Object?>? _pendingResult;

  /// Throws [ArgumentError] when the push awaiting this entry cannot take
  /// [result]. An entry nobody awaits takes anything and drops it.
  void checkResult(Object? result) {
    if (_pendingResult case final pending? when !pending.accepts(result)) {
      throw pending.mismatch(route, result);
    }
  }

  /// Keeps [result] for the push, which completes when the entry leaves.
  void recordResult(Object? result) => _pendingResult?.record(result);

  /// Keeps a [result] the navigator popped this page with
  /// (`Navigator.pop(context, result)`). One of another type is reported
  /// through [FlutterError.reportError] and dropped: the navigator is in
  /// the middle of a pop and must not be interrupted.
  void offerNativeResult(Object? result) {
    if (_pendingResult case final pending? when !pending.accepts(result)) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: pending.mismatch(route, result),
          library: 'typed_navigator',
          context: ErrorDescription('while Navigator.pop closed $route'),
        ),
      );
      return;
    }
    recordResult(result);
  }

  /// Whether leaving this entry completes [pendingResult]: the push that
  /// created it awaits this entry.
  bool completes(PendingResult<Object?> pendingResult) =>
      identical(_pendingResult, pendingResult);

  /// The entry left the state: completes the push awaiting it.
  void leave() => _pendingResult?.complete();

  @override
  String toString() => 'NavigationEntry($route)';
}
