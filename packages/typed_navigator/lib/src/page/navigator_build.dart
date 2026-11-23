import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/level_pages.dart';
import 'package:typed_navigator/src/page/navigator_observers.dart';
import 'package:typed_navigator/src/page/nested_hero_controller.dart';
import 'package:typed_navigator/src/page/on_screen_level.dart';
import 'package:typed_navigator/src/page/route_pages.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/src/state/stack_parts.dart';

/// One build of the navigators for [_state]: the pages of every
/// navigator, each nested navigator inside the page of its level.
class NavigatorBuild {
  /// Creates one build of the navigators for [_state].
  NavigatorBuild({
    required this._routePages,
    required this._levelPages,
    required this._state,
    required this._onDidRemovePage,
    required this._observers,
  });

  final RoutePages _routePages;
  final LevelPages _levelPages;
  final NavigationState _state;
  final void Function(Page<Object?> page) _onDidRemovePage;
  final NavigatorObservers _observers;
  final StackParts _parts = const StackParts();

  /// The pages of the navigator holding [entries], whose levels above
  /// [depth] are shared.
  List<Page<Object?>> pagesAt(List<NavigationEntry> entries, int depth) => [
    for (final part in _parts.of(entries, depth))
      switch (part) {
        RoutePart(:final entry) => _routePages.pageFor(entry),
        LevelPart(:final level, :final entries) => switch (level) {
          ShellEntry() => _levelPages.shellPage(
            level,
            _state,
            _navigator(level, entries, depth + 1, isActive: true),
          ),
          BranchEntry() => _levelPages.tabsPage(
            level,
            _state,
            _branchNavigators(level, entries, depth + 1),
          ),
        },
      },
  ];

  Map<Type, Widget> _branchNavigators(
    BranchEntry active,
    List<NavigationEntry> activeEntries,
    int depth,
  ) {
    final tabs = active.tabs;
    return {
      for (final branchType in tabs.branchTypes)
        if (branchType == active.branchType)
          branchType: _navigator(active, activeEntries, depth, isActive: true)
        else if (_state.inactiveBranches.stackOf(tabs, branchType)
            case final stack?)
          branchType: _navigator(
            tabs.branch(branchType),
            stack,
            depth,
            isActive: false,
          ),
    };
  }

  /// The navigator of [level] with [entries]; [isActive] when it is a shell's
  /// or the active branch's.
  Widget _navigator(
    ShellLevel level,
    List<NavigationEntry> entries,
    int depth, {
    required bool isActive,
  }) => OnScreenLevel(
    isActive: isActive,
    // A semantics boundary, as go_router's: without it, the barrier of a route
    // in this navigator drops the frame painted before it.
    child: Semantics(
      container: true,
      explicitChildNodes: true,
      // Heroes fly inside the navigator, as go_router's. Keyed by the level, so
      // the controller moves with the navigator when a frame moves it in the
      // tree, mid-flight too.
      child: NestedHeroController(
        key: GlobalObjectKey(level.navigatorKey),
        child: Navigator(
          key: level.navigatorKey,
          pages: pagesAt(entries, depth),
          onDidRemovePage: _onDidRemovePage,
          observers: _observers.of(level),
        ),
      ),
    ),
  );
}
