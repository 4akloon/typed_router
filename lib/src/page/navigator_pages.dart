import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/page_factory.dart';
import 'package:typed_navigator/src/page/page_request.dart';
import 'package:typed_navigator/src/page/route_pages.dart';
import 'package:typed_navigator/src/redirect/redirect_error_screen.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_entry.dart';

/// Turns a [NavigationState] into the pages of the root navigator, with a
/// navigator of its own in every shell.
///
/// Entries that stand in the same shell instance, one after another, become one
/// shell page whose builder frames the shell's navigator; inside it the same
/// rule applies one level deeper. A state whose redirects failed becomes the
/// error screen alone.
final class NavigatorPages {
  /// Creates the pages with [_routePages] for routes, the router's
  /// [_pageFactory] for shells without their own and for the error screen,
  /// which [_errorBuilder] builds (a plain one when it is `null`).
  NavigatorPages({
    required this._routePages,
    required this._pageFactory,
    this._errorBuilder,
  });

  final RoutePages _routePages;
  final PageFactory _pageFactory;
  final Widget Function(BuildContext context, Object error)? _errorBuilder;

  /// The pages of the root navigator for [state], bottom to top. Every
  /// navigator reports the pages it removes itself to [onDidRemovePage].
  List<Page<Object?>> pagesFor(
    NavigationState state, {
    required void Function(Page<Object?> page) onDidRemovePage,
  }) => switch (state.error) {
    final error? => [_errorPage(error)],
    null => _pagesAt(state.entries, 0, state, onDidRemovePage),
  };

  /// The entries a page of [pagesFor] stands for: one for a route page,
  /// every entry of the shell for a shell page; none for a page this
  /// router did not create.
  List<NavigationEntry> entriesOf(Page<Object?> page, NavigationState state) =>
      switch (page.key) {
        ValueKey<NavigationEntry>(:final value) => [value],
        ObjectKey(value: final ShellEntry shell) => [
          for (final entry in state.entries)
            if (entry.shells.contains(shell)) entry,
        ],
        _ => const [],
      };

  List<Page<Object?>> _pagesAt(
    List<NavigationEntry> entries,
    int level,
    NavigationState state,
    void Function(Page<Object?> page) onDidRemovePage,
  ) {
    final pages = <Page<Object?>>[];
    var index = 0;
    while (index < entries.length) {
      final entry = entries[index];
      if (entry.shells.length == level) {
        pages.add(_routePages.pageFor(entry));
        index++;
        continue;
      }
      final shell = entry.shells[level];
      final group = entries
          .skip(index)
          .takeWhile(
            (member) =>
                member.shells.length > level && member.shells[level] == shell,
          )
          .toList();
      final navigator = Navigator(
        key: shell.navigatorKey,
        pages: _pagesAt(group, level + 1, state, onDidRemovePage),
        onDidRemovePage: onDidRemovePage,
      );
      pages.add(_shellPage(shell, state, navigator));
      index += group.length;
    }
    return pages;
  }

  Page<Object?> _shellPage(
    ShellEntry shell,
    NavigationState state,
    Widget navigator,
  ) => _routePages.created(
    shell.node.pageFactoryOr(_pageFactory),
    PageRequest(
      key: ObjectKey(shell),
      child: Builder(
        builder: (context) => shell.node.builder(context, state, navigator),
      ),
    ),
    'a shell',
  );

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
