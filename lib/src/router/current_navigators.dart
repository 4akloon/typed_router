import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';

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
    final navigators = [root];
    final top = state.entries.last;
    for (final level in top.levels) {
      final keys = level.navigatorKeysToward(top);
      final mounted = [for (final key in keys) ?key.currentState];
      if (mounted.isEmpty) break;
      for (final navigator in mounted) {
        if (!_isOnTop(navigator)) return navigators.reversed.toList();
        navigators.add(navigator);
      }
    }
    return navigators.reversed.toList();
  }

  /// Whether the shell page holding [navigator] is the current route of
  /// the navigator around it.
  bool _isOnTop(NavigatorState navigator) =>
      ModalRoute.isCurrentOf(navigator.context) ?? false;
}
