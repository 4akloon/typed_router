import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/level_pages.dart';
import 'package:typed_navigator/src/page/navigator_build.dart';
import 'package:typed_navigator/src/page/navigator_observers.dart';
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
  /// shells and tabs, the router's [_pageFactory] for the error screen,
  /// which [_errorBuilder] builds (a plain one when it is `null`), and the
  /// nested navigators' [_observers].
  NavigatorPages({
    required this._routePages,
    required this._levelPages,
    required this._pageFactory,
    required this._observers,
    this._errorBuilder,
  });

  final RoutePages _routePages;
  final LevelPages _levelPages;
  final PageFactory _pageFactory;
  final NavigatorObservers _observers;
  final Widget Function(BuildContext context, Object error)? _errorBuilder;

  /// The pages of the root navigator for [state], bottom to top. Every
  /// navigator reports the pages it removes itself to [onDidRemovePage].
  List<Page<Object?>> pagesFor(
    NavigationState state, {
    required void Function(Page<Object?> page) onDidRemovePage,
  }) => switch (state.error) {
    final error? => [_errorPage(error)],
    null => NavigatorBuild(
      routePages: _routePages,
      levelPages: _levelPages,
      state: state,
      onDidRemovePage: onDidRemovePage,
      observers: _observers,
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
