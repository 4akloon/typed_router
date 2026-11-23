import 'package:flutter/widgets.dart';
import 'package:typed_router/src/state/shell_level.dart';
import 'package:typed_router/src/state/typed_router_state.dart';

/// The navigators the system back button goes to, deepest first, as go_router's
/// `_findCurrentNavigators`.
///
/// Starts at the root and follows the levels (shells, branches) of the top
/// entry inward; stops at a level whose page is not current (a dialog or
/// another page above it), so back reaches that first.
class CurrentNavigators {
  /// Creates the lookup.
  const CurrentNavigators();

  /// The current navigators for [state] under [root], the deepest first.
  List<NavigatorState> deepestFirst(
    NavigatorState root,
    TypedRouterState state,
  ) => [root, ..._outermostFirst(state.topLevels)].reversed.toList();

  /// The current navigators of [level] and of the levels inside it, the deepest
  /// first; none when the top entry of [state] is not in [level] or the page
  /// holding [level] is not current.
  List<NavigatorState> insideDeepestFirst(
    ShellLevel level,
    TypedRouterState state,
  ) {
    final levels = state.topLevels;
    final index = levels.indexOf(level);
    if (index < 0) return const [];
    return _outermostFirst(levels.sublist(index)).reversed.toList();
  }

  /// The mounted navigators of [levels], outer first, up to the first
  /// whose page is not current.
  List<NavigatorState> _outermostFirst(List<ShellLevel> levels) {
    final navigators = <NavigatorState>[];
    for (final level in levels) {
      final navigator = level.navigatorKey.currentState;
      if (navigator == null || !_isOnTop(navigator)) break;
      navigators.add(navigator);
    }
    return navigators;
  }

  /// Whether the shell page holding [navigator] is the current route of
  /// the navigator around it.
  bool _isOnTop(NavigatorState navigator) =>
      ModalRoute.isCurrentOf(navigator.context) ?? false;
}
