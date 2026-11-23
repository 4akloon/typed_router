import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/router/current_navigators.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/src/state/typed_router_state.dart';

/// What is inside a level's page (a shell's or a tabs instance's) for back: the
/// current navigators of the level and of the levels inside it, toward the top
/// entry of the state.
class LevelInside {
  /// Creates the view of [_level] in [_state]; [_currentNavigators] finds
  /// the navigators.
  const LevelInside(this._level, this._state, this._currentNavigators);

  final ShellLevel _level;
  final TypedRouterState _state;
  final CurrentNavigators _currentNavigators;

  /// Whether back inside is handled there, as Flutter's
  /// `NavigatorPopHandler` counts it: a navigator inside can pop, or the
  /// route on top of one refuses (an app's `PopScope(canPop: false)`), as
  /// the navigators hold it now.
  bool canHandlePop() {
    final navigators = _currentNavigators.insideDeepestFirst(_level, _state);
    if (navigators.isEmpty) return false;
    if (navigators.any((navigator) => navigator.canPop())) return true;
    return _routesOnTop(navigators).any(
      (disposition) => disposition == RoutePopDisposition.doNotPop,
    );
  }

  /// Gives back to the navigators inside, the deepest first, as the system
  /// back button does: the first that does not bubble it up takes it.
  Future<void> maybePop() async {
    final navigators = _currentNavigators.insideDeepestFirst(_level, _state);
    for (final navigator in navigators) {
      if (await navigator.maybePop()) return;
    }
  }

  /// How the route on top of each navigator in [deepestFirst] answers a
  /// pop: the top entry's page in the deepest, then the pages holding the
  /// deeper navigators. The level's own page is not asked: it is the one
  /// asking.
  Iterable<RoutePopDisposition?> _routesOnTop(
    List<NavigatorState> deepestFirst,
  ) => [
    switch (_state.entries.last.screenKey.currentContext) {
      final screen? => ModalRoute.popDispositionOf(screen),
      null => null,
    },
    for (final navigator in deepestFirst.take(deepestFirst.length - 1))
      ModalRoute.popDispositionOf(navigator.context),
  ];
}
