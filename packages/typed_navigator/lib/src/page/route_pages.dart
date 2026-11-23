import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/on_screen_gate.dart';
import 'package:typed_navigator/src/page/page_factory.dart';
import 'package:typed_navigator/src/page/page_request.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';

// Messages name the route and result types; type names are readable in debug
// builds, where these errors are met.
// ignore_for_file: avoid_type_to_string

/// Makes the page of one route entry: its node builds the screen, the
/// node's own factory or the router's makes the page, keyed by the entry.
class RoutePages {
  /// Creates pages for routes of `tree`, with `pageFactory` for nodes that
  /// have no factory of their own.
  RoutePages({required this._tree, required this._pageFactory});

  final RouteTree _tree;
  final PageFactory _pageFactory;

  /// The page of [entry].
  Page<Object?> pageFor(NavigationEntry entry) {
    final route = entry.route;
    final node = _tree.nodeFor(route);
    final request = PageRequest(
      key: ValueKey(entry),
      name: node.name,
      child: KeyedSubtree(
        key: entry.screenKey,
        child: OnScreenGate(
          entry: entry,
          child: Builder(
            builder: (context) => node.buildScreen(context, route),
          ),
        ),
      ),
    );
    return created(
      node.pageFactoryOr(_pageFactory),
      request,
      node.describe(route),
    );
  }

  /// The page [factory] creates for [request], which shows [description];
  /// throws [StateError] when the factory dropped the request's key or name.
  Page<Object?> created(
    PageFactory factory,
    PageRequest request,
    String description,
  ) {
    final page = factory.createPage(request);
    if (page.key != request.key) {
      throw StateError(
        '${factory.runtimeType} created a page for $description without '
        'request.key. Pass `key: request.key` to the page.',
      );
    }
    if (page.name != request.name) {
      throw StateError(
        '${factory.runtimeType} created a page for $description without '
        'request.name. Pass `name: request.name` to the page.',
      );
    }
    return page;
  }
}
