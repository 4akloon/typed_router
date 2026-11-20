import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/level_pages.dart';
import 'package:typed_navigator/src/page/nested_navigator.dart';
import 'package:typed_navigator/src/page/route_pages.dart';
import 'package:typed_navigator/src/split/split_part.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/src/state/stack_parts.dart';

/// One build of the navigators for [_state]: the pages of every
/// navigator, each nested navigator inside the page of its level.
final class NavigatorBuild {
  /// Creates one build of the navigators for [_state].
  NavigatorBuild({
    required this._routePages,
    required this._levelPages,
    required this._state,
    required this._onDidRemovePage,
    required this._onDidRemoveColumn,
  });

  final RoutePages _routePages;
  final LevelPages _levelPages;
  final NavigationState _state;
  final void Function(Page<Object?> page) _onDidRemovePage;
  final void Function(Page<Object?> page, SplitEntry split) _onDidRemoveColumn;
  final StackParts _parts = const StackParts();

  /// The pages of the navigator holding [entries], whose levels above
  /// [depth] are shared.
  List<Page<Object?>> pagesAt(List<NavigationEntry> entries, int depth) => [
    for (final part in _parts.of(entries, depth))
      switch (part) {
        RoutePart(:final entry) => _routePages.pageFor(entry),
        LevelPart(:final level, :final entries) => _levelPage(
          level,
          entries,
          depth,
        ),
      },
  ];

  /// The page of [level] holding its navigators with [entries].
  Page<Object?> _levelPage(
    ShellLevel level,
    List<NavigationEntry> entries,
    int depth,
  ) => switch (level) {
    ShellEntry() => _levelPages.shellPage(
      level,
      _state,
      _navigator(level, entries, depth + 1, isActive: true),
    ),
    SplitEntry() => _levelPages.splitPage(
      level,
      _state,
      _splitParts(entries, depth + 1),
      onDidRemovePage: _onDidRemovePage,
      onDidRemoveColumn: _onDidRemoveColumn,
    ),
    BranchEntry() => _levelPages.tabsPage(
      level,
      _state,
      _branchNavigators(level, entries, depth + 1),
    ),
  };

  /// The parts of a split's stack: its routes, and the levels nested right
  /// inside it.
  List<SplitPart> _splitParts(List<NavigationEntry> entries, int depth) => [
    for (final part in _parts.of(entries, depth))
      switch (part) {
        RoutePart(:final entry) => _routePages.splitPartFor(entry),
        LevelPart(:final level, :final entries) => SplitPart(
          owner: level.columnOwner,
          page: _levelPage(level, entries, depth),
          route: entries.last.route,
          topScreenKey: entries.last.screenKey,
        ),
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
  }) => NestedNavigator(
    navigatorKey: level.navigatorKey,
    pages: pagesAt(entries, depth),
    onDidRemovePage: _onDidRemovePage,
    isActive: isActive,
  );
}
