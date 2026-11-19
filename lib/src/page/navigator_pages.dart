import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/level_pages.dart';
import 'package:typed_navigator/src/page/page_factory.dart';
import 'package:typed_navigator/src/page/page_request.dart';
import 'package:typed_navigator/src/page/route_pages.dart';
import 'package:typed_navigator/src/redirect/redirect_error_screen.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/src/state/stack_parts.dart';

/// Turns a [NavigationState] into the pages of the root navigator, with a
/// navigator of its own in every shell and every visited branch of tabs.
///
/// Entries that stand in the same level, one after another, become one page
/// holding that level's navigator; inside it the same rule applies one level
/// deeper. A state whose redirects failed becomes the error screen alone.
final class NavigatorPages {
  /// Creates the pages with [_routePages] for routes, [_levelPages] for
  /// shells and tabs, and the router's [_pageFactory] for the error screen,
  /// which [_errorBuilder] builds (a plain one when it is `null`).
  NavigatorPages({
    required this._routePages,
    required this._levelPages,
    required this._pageFactory,
    this._errorBuilder,
  });

  final RoutePages _routePages;
  final LevelPages _levelPages;
  final PageFactory _pageFactory;
  final Widget Function(BuildContext context, Object error)? _errorBuilder;

  /// The pages of the root navigator for [state], bottom to top. Every
  /// navigator reports the pages it removes itself to [onDidRemovePage].
  List<Page<Object?>> pagesFor(
    NavigationState state, {
    required void Function(Page<Object?> page) onDidRemovePage,
  }) => switch (state.error) {
    final error? => [_errorPage(error)],
    null => _NavigatorBuild(
      routePages: _routePages,
      levelPages: _levelPages,
      state: state,
      onDidRemovePage: onDidRemovePage,
    ).pagesAt(state.entries, 0),
  };

  /// The entries a page of [pagesFor] stands for: one for a route page,
  /// every entry of the instance for a shell or tabs page; none for a page
  /// this router did not create.
  List<NavigationEntry> entriesOf(Page<Object?> page, NavigationState state) =>
      switch (page.key) {
        ValueKey<NavigationEntry>(:final value) => [value],
        ObjectKey(value: final ShellEntry shell) => [
          for (final entry in state.entries)
            if (entry.isIn(shell)) entry,
        ],
        ObjectKey(value: final TabsEntry tabs) => [
          for (final entry in state.entries)
            if (entry.standsIn(tabs)) entry,
        ],
        _ => const [],
      };

  Page<Object?> _errorPage(Object error) => _routePages.created(
    _pageFactory,
    PageRequest(
      key: ObjectKey(error),
      child: Builder(
        builder: (context) => switch (_errorBuilder) {
          final errorBuilder? => errorBuilder(context, error),
          null => RedirectErrorScreen(error: error),
        },
      ),
    ),
    'the error screen',
  );
}

/// One build of the navigators for [_state]: the pages of every
/// navigator, each nested navigator inside the page of its level.
final class _NavigatorBuild {
  _NavigatorBuild({
    required this._routePages,
    required this._levelPages,
    required this._state,
    required this._onDidRemovePage,
  });

  final RoutePages _routePages;
  final LevelPages _levelPages;
  final NavigationState _state;
  final void Function(Page<Object?> page) _onDidRemovePage;
  final StackParts _parts = const StackParts();

  List<Page<Object?>> pagesAt(List<NavigationEntry> entries, int depth) => [
    for (final part in _parts.of(entries, depth))
      switch (part) {
        RoutePart(:final entry) => _routePages.pageFor(entry),
        LevelPart(:final level, :final entries) => switch (level) {
          ShellEntry() => _levelPages.shellPage(
            level,
            _state,
            _navigator(level, entries, depth + 1),
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
          branchType: _navigator(active, activeEntries, depth)
        else if (_state.inactiveBranches.stackOf(tabs, branchType)
            case final stack?)
          branchType: _navigator(tabs.branch(branchType), stack, depth),
    };
  }

  Widget _navigator(
    ShellLevel level,
    List<NavigationEntry> entries,
    int depth,
  ) => Navigator(
    key: level.navigatorKey,
    pages: pagesAt(entries, depth),
    onDidRemovePage: _onDidRemovePage,
  );
}
