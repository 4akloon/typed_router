import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';

/// The navigators the system back button goes to, deepest first, as go_router's
/// `_findCurrentNavigators`.
///
/// Starts at the root and follows the shells of the top entry inward;
/// stops at a shell whose page is not current (a dialog or another page
/// above it), so back reaches that first.
final class CurrentNavigators {
  /// Creates the lookup from the root navigator's [_rootKey].
  CurrentNavigators(this._rootKey);

  final GlobalKey<NavigatorState> _rootKey;

  /// The current navigators for [state], the deepest first; empty while the
  /// router is not shown.
  List<NavigatorState> deepestFirst(NavigationState state) {
    final root = _rootKey.currentState;
    if (root == null) return const [];
    final navigators = [root];
    for (final shell in state.entries.last.shells) {
      final navigator = shell.navigatorKey.currentState;
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
