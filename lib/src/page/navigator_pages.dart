import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/level_pages.dart';
import 'package:typed_navigator/src/page/navigator_build.dart';
import 'package:typed_navigator/src/page/page_factory.dart';
import 'package:typed_navigator/src/page/page_request.dart';
import 'package:typed_navigator/src/page/route_pages.dart';
import 'package:typed_navigator/src/redirect/redirect_error_screen.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';

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
  /// navigator reports the pages it removes itself to [onDidRemovePage],
  /// the navigator of a split's column to [onDidRemoveColumn].
  List<Page<Object?>> pagesFor(
    NavigationState state, {
    required void Function(Page<Object?> page) onDidRemovePage,
    required void Function(Page<Object?> page, SplitEntry split)
    onDidRemoveColumn,
  }) => switch (state.error) {
    final error? => [_errorPage(error)],
    null => NavigatorBuild(
      routePages: _routePages,
      levelPages: _levelPages,
      state: state,
      onDidRemovePage: onDidRemovePage,
      onDidRemoveColumn: onDidRemoveColumn,
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
        ObjectKey(value: final SplitEntry split) => [
          for (final entry in state.entries)
            if (entry.isIn(split)) entry,
        ],
        ObjectKey(value: final TabsEntry tabs) => [
          for (final entry in state.entries)
            if (entry.standsIn(tabs)) entry,
        ],
        _ => const [],
      };

  /// The entries a column of [split] stands for, with every entry above them in
  /// [split]: a column closes with the ones to its right.
  List<NavigationEntry> columnEntriesOf(
    Page<Object?> page,
    SplitEntry split,
    NavigationState state,
  ) {
    final removed = entriesOf(page, state);
    if (removed.isEmpty) return removed;
    final first = state.entries.indexOf(removed.first);
    // Not on screen: already gone, or in a branch not shown, whose kept
    // stack loses only these entries.
    if (first < 0) return removed;
    return [
      for (final entry in state.entries.skip(first))
        if (entry.isIn(split)) entry,
    ];
  }

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
