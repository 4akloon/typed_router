import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';

/// The navigators the system back button goes to, deepest first, as go_router's
/// `_findCurrentNavigators`.
///
/// Starts at the root and follows the levels (shells, splits, branches) of
/// the top entry inward, and in a split showing columns, the column of the
/// top entry; stops at a navigator whose page is not current (a dialog or
/// another page above it), so back reaches that first.
final class CurrentNavigators {
  /// Creates the lookup.
  const CurrentNavigators();

  /// The current navigators for [state] under [root], the deepest first.
  List<NavigatorState> deepestFirst(
    NavigatorState root,
    NavigationState state,
  ) {
    final top = state.entries.last;
    return [root, ..._outermostFirst(top.levels, top)].reversed.toList();
  }

  /// The current navigators of [level] and of the levels inside it, the deepest
  /// first; none when the top entry of [state] is not in [level] or the page
  /// holding [level] is not current.
  List<NavigatorState> insideDeepestFirst(
    ShellLevel level,
    NavigationState state,
  ) {
    final top = state.entries.last;
    final index = top.levels.indexOf(level);
    if (index < 0) return const [];
    return _outermostFirst(
      top.levels.sublist(index),
      top,
    ).reversed.toList();
  }

  /// The mounted navigators of [levels] toward [top], outer first, up to
  /// the first whose page is not current.
  List<NavigatorState> _outermostFirst(
    List<ShellLevel> levels,
    NavigationEntry top,
  ) {
    final navigators = <NavigatorState>[];
    for (final level in levels) {
      final keys = level.navigatorKeysToward(top);
      final mounted = [for (final key in keys) ?key.currentState];
      if (mounted.isEmpty) break;
      for (final navigator in mounted) {
        if (!_isOnTop(navigator)) return navigators;
        navigators.add(navigator);
      }
    }
    return navigators;
  }

  /// Whether the shell page holding [navigator] is the current route of
  /// the navigator around it.
  bool _isOnTop(NavigatorState navigator) =>
      ModalRoute.isCurrentOf(navigator.context) ?? false;
}
