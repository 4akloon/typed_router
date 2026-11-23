import 'package:flutter/widgets.dart';
import 'package:typed_router/src/exit/exit_back_gate.dart';
import 'package:typed_router/src/exit/last_page_exit.dart';
import 'package:typed_router/src/page/on_screen_gate.dart';
import 'package:typed_router/src/page/page_factory.dart';
import 'package:typed_router/src/page/page_request.dart';
import 'package:typed_router/src/route/typed_route.dart';
import 'package:typed_router/src/state/navigation_entry.dart';
import 'package:typed_router/src/tree/route_tree.dart';
import 'package:typed_router/src/tree/tree_node.dart';

// A node without a name is named by its route type (a branch by its type)
// in these messages; type names are readable in debug builds, where these
// errors are met.
// ignore_for_file: avoid_type_to_string

/// Makes the page of one route entry: its node builds the screen, the
/// node's own factory or the router's makes the page, keyed by the entry.
class RoutePages {
  /// Creates pages for routes of `tree`, with `pageFactory` for nodes that
  /// have no factory of their own.
  /// [lastPageExit] asks before back leaves the app from the only page.
  RoutePages({
    required this._tree,
    required this._pageFactory,
    required this._lastPageExit,
  });

  final RouteTree _tree;
  final PageFactory _pageFactory;
  final LastPageExit _lastPageExit;

  /// The page of [entry].
  Page<Object?> pageFor(NavigationEntry entry) {
    final route = entry.route;
    final node = _tree.nodeFor(route);
    final request = PageRequest(
      key: ValueKey(entry.page),
      name: node.name,
      child: KeyedSubtree(
        key: entry.screenKey,
        child: OnScreenGate(
          entry: entry,
          child: _withExitGate(
            node,
            entry,
            Builder(builder: (context) => node.buildScreen(context, route)),
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

  /// [screen] behind an [ExitBackGate] when [node] asks before it leaves.
  Widget _withExitGate(
    RouteNode<TypedRoute<Object?>> node,
    NavigationEntry entry,
    Widget screen,
  ) => node.asksOnExit
      ? ExitBackGate(entry: entry, lastPageExit: _lastPageExit, child: screen)
      : screen;

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
