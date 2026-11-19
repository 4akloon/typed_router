import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/navigator_pages.dart';
import 'package:typed_navigator/src/router/typed_router.dart';
import 'package:typed_navigator/src/router/typed_router_scope.dart';
import 'package:typed_navigator/src/transaction/navigation_controller.dart';

/// Shows the router's state in the root navigator and brings back the
/// pages the navigator removes by itself.
///
/// [Router] listens to it, so every commit rebuilds the navigator.
final class TypedRouterDelegate extends RouterDelegate<Object> {
  /// Creates the delegate of `router`, showing `controller`'s state as
  /// `pages`.
  TypedRouterDelegate({
    required this._router,
    required this._controller,
    required this._pages,
  });

  final TypedRouter _router;
  final NavigationController _controller;
  final NavigatorPages _pages;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  /// The root navigator, or `null` while it is not mounted.
  NavigatorState? get navigator => _navigatorKey.currentState;

  @override
  void addListener(VoidCallback listener) => _controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _controller.removeListener(listener);

  @override
  Widget build(BuildContext context) => TypedRouterScope(
    router: _router,
    child: Navigator(
      key: _navigatorKey,
      pages: _pages.pagesFor(_controller.state),
      onDidRemovePage: _removePage,
    ),
  );

  /// Called for pages the navigator popped (back in an app bar, a swipe, a
  /// predictive back gesture) and for pages the router took away; only the
  /// first changes the state.
  void _removePage(Page<Object?> page) {
    if (_pages.entryOf(page) case final entry?) {
      _controller.applyExternalChange(_controller.state.withoutEntry(entry));
    }
  }

  /// The platform's back button, as the native navigator answers it:
  /// `maybePop` closes a dialog first, respects `PopScope`, and on the
  /// first page answers `false` so the platform closes the app.
  @override
  Future<bool> popRoute() => navigator?.maybePop() ?? SynchronousFuture(false);

  /// Not called: the router has no route information parser until URLs
  /// (0.5).
  @override
  Future<void> setNewRoutePath(Object configuration) => SynchronousFuture(null);
}
