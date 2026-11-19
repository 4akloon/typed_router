import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';

/// The navigators the system back button goes to, deepest first, as go_router's
/// `_findCurrentNavigators`.
///
/// Starts at the root and follows the levels (shells, branches) of the top
/// entry inward; stops at a level whose page is not current (a dialog or
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
    for (final level in state.topLevels) {
      final navigator = level.navigatorKey.currentState;
      if (navigator == null || !_isOnTop(navigator)) break;
      navigators.add(navigator);
    }
    return navigators.reversed.toList();
  }

  /// Whether the shell page holding [navigator] is the current route of
  /// the navigator around it.
  bool _isOnTop(NavigatorState navigator) =>
      ModalRoute.isCurrentOf(navigator.context) ?? false;
}
