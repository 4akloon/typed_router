import 'package:flutter/widgets.dart';
import 'package:typed_router/src/state/navigation_entry.dart';
import 'package:typed_router/src/state/shell_level.dart';
import 'package:typed_router/src/state/typed_router_state.dart';

/// Makes anew a page a navigator popped by itself while nothing would be left
/// under it.
///
/// The state keeps the page, so the navigator must show it again; but the
/// popped route is still leaving, and its screen holds the keys of the
/// entry (and, for a shell's or tabs' page, of its levels). The page comes
/// back with new entries and new levels, so the two never share a key,
/// however often the navigator is rebuilt meanwhile.
class RenewedPage {
  /// Creates the renewal.
  const RenewedPage();

  /// [state] with the page keyed by [pageKey] made anew: a route page's
  /// entry, or a shell's or tabs' page with its levels inward and the
  /// entries in them. [left] are the entries of the popped page, on screen
  /// and in branches not on screen; those not on screen are dropped with
  /// their levels.
  TypedRouterState renewing(
    TypedRouterState state,
    LocalKey? pageKey,
    List<NavigationEntry> left,
  ) {
    final levels = _Levels();
    bool isPageLevel(ShellLevel level) => switch ((pageKey, level)) {
      (ObjectKey(value: final ShellEntry shell), _) => identical(level, shell),
      (ObjectKey(value: final TabsEntry tabs), final BranchEntry branch) =>
        identical(branch.tabs, tabs),
      _ => false,
    };
    NavigationEntry renewed(NavigationEntry entry) {
      final index = entry.levels.indexWhere(isPageLevel);
      final kept = index < 0 ? entry.levels : entry.levels.take(index);
      return NavigationEntry(
        entry.route,
        levels: [
          ...kept,
          if (index >= 0) ...entry.levels.skip(index).map(levels.renewed),
        ],
      );
    }

    return state
        .showing([
          for (final entry in state.entries)
            if (left.contains(entry)) renewed(entry) else entry,
        ])
        .withoutEntries(left);
  }
}

/// New levels for old ones: one new shell per shell, one new tabs per tabs
/// with the same branch types.
class _Levels {
  final Map<ShellLevel, ShellLevel> _renewed = {};
  final Map<TabsEntry, TabsEntry> _tabs = {};

  ShellLevel renewed(ShellLevel level) => _renewed.putIfAbsent(
    level,
    () => switch (level) {
      ShellEntry(:final node) => ShellEntry(node),
      BranchEntry(:final tabs, :final branchType) =>
        _tabs.putIfAbsent(tabs, () => TabsEntry(tabs.node)).branch(branchType),
    },
  );
}
