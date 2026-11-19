import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/navigator_pages.dart';
import 'package:typed_navigator/src/redirect/redirect_scope.dart';
import 'package:typed_navigator/src/redirect/router_mount.dart';
import 'package:typed_navigator/src/redirect/stack_recheck.dart';
import 'package:typed_navigator/src/router/current_navigators.dart';
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
    required this._mount,
    required this._recheck,
  });

  final TypedRouter _router;
  final NavigationController _controller;
  final NavigatorPages _pages;
  final RouterMount _mount;
  final StackRecheck _recheck;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  late final CurrentNavigators _currentNavigators = CurrentNavigators(
    _navigatorKey,
  );

  /// The root navigator, or `null` while it is not mounted.
  NavigatorState? get navigator => _navigatorKey.currentState;

  @override
  void addListener(VoidCallback listener) => _controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _controller.removeListener(listener);

  @override
  Widget build(BuildContext context) => RedirectScope(
    key: ObjectKey(_router),
    mount: _mount,
    recheckWhileBuilding: _recheck.recheckWhileBuilding,
    // Reads the state on every build: a re-check while building shows in the
    // same frame.
    builder: (context) => TypedRouterScope(
      router: _router,
      child: Navigator(
        key: _navigatorKey,
        pages: _pages.pagesFor(
          _controller.state,
          onDidRemovePage: _removePage,
        ),
        onDidRemovePage: _removePage,
      ),
    ),
  );

  /// Called for pages the navigator popped (back in an app bar, a swipe, a
  /// predictive back gesture) and for pages the router took away; only the
  /// first changes the state. A page some navigator popped by itself.
  void _removePage(Page<Object?> page) {
    final state = _controller.state;
    final removed = _pages.entriesOf(page, state);
    if (removed.isEmpty) return;
    _controller.applyExternalChange(state.withoutEntries(removed));
  }

  /// The platform's back button, as the native navigator answers it: `maybePop`
  /// closes a dialog first, respects `PopScope`, and on the first page answers
  /// `false` so the platform closes the app. The system back button: `maybePop`
  /// on the current navigators, the deepest first, until one handles it.
  /// `false` lets the platform close the app.
  @override
  Future<bool> popRoute() async {
    for (final navigator in _currentNavigators.deepestFirst(
      _controller.state,
    )) {
      if (await navigator.maybePop()) return true;
    }
    return false;
  }

  /// Not called: the router has no route information parser until URLs
  /// (0.5).
  @override
  Future<void> setNewRoutePath(Object configuration) => SynchronousFuture(null);
}
