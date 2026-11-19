import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/page_factory.dart';
import 'package:typed_navigator/src/page/page_request.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';

// Messages name the route and result types; type names are readable in debug
// builds, where these errors are met.
// ignore_for_file: avoid_type_to_string

/// Turns a [NavigationState] into the pages of the navigator.
///
/// Each entry becomes one page: its node builds the screen, the node's own
/// factory or the router's makes the page, keyed by the entry.
final class NavigatorPages {
  /// Creates pages for routes of `tree`, with `pageFactory` for nodes that
  /// have no factory of their own.
  NavigatorPages({required this._tree, required this._pageFactory});

  final RouteTree _tree;
  final PageFactory _pageFactory;

  /// The pages for [state], bottom to top.
  List<Page<Object?>> pagesFor(NavigationState state) => [
    for (final entry in state.entries) _pageFor(entry),
  ];

  /// The entry a page of [pagesFor] stands for, or `null` for a page this
  /// router did not create.
  NavigationEntry? entryOf(Page<Object?> page) => switch (page.key) {
    ValueKey<NavigationEntry>(:final value) => value,
    _ => null,
  };

  Page<Object?> _pageFor(NavigationEntry entry) {
    final route = entry.route;
    final node = _tree.nodeFor(route);
    final factory = node.pageFactoryOr(_pageFactory);
    final request = PageRequest(
      key: ValueKey(entry),
      // The navigator reports a native Navigator.pop(context, result) here,
      // just before onDidRemovePage; Route.popped would arrive too late.
      child: PopScope<Object?>(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) entry.offerNativeResult(result);
        },
        child: Builder(builder: (context) => node.buildScreen(context, route)),
      ),
    );
    final page = factory.createPage(request);
    if (page.key != request.key) {
      throw StateError(
        '${factory.runtimeType} created a page for $route without '
        'request.key. Pass `key: request.key` to the page.',
      );
    }
    return page;
  }
}
