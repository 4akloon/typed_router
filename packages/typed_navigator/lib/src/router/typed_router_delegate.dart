import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/hero_flight_scope.dart';
import 'package:typed_navigator/src/page/navigator_hero_controller.dart';
import 'package:typed_navigator/src/page/navigator_pages.dart';
import 'package:typed_navigator/src/redirect/redirect_scope.dart';
import 'package:typed_navigator/src/redirect/router_mount.dart';
import 'package:typed_navigator/src/redirect/stack_recheck.dart';
import 'package:typed_navigator/src/router/current_navigators.dart';
import 'package:typed_navigator/src/router/navigation_state_scope.dart';
import 'package:typed_navigator/src/router/typed_router.dart';
import 'package:typed_navigator/src/router/typed_router_scope.dart';
import 'package:typed_navigator/src/state/renewed_page.dart';
import 'package:typed_navigator/src/transaction/navigation_controller.dart';

/// Shows the router's state in the root navigator and brings back the
/// pages the navigator removes by itself.
///
/// [Router] listens to it, so every commit rebuilds the navigator.
class TypedRouterDelegate extends RouterDelegate<Object> {
  /// Creates the delegate of `router`, showing `controller`'s state as
  /// `pages`.
  TypedRouterDelegate({
    required this._router,
    required this._controller,
    required this._pages,
    required this._mount,
    required this._recheck,
    required this._observers,
  });

  final TypedRouter _router;
  final NavigationController _controller;
  final NavigatorPages _pages;
  final RouterMount _mount;
  final StackRecheck _recheck;
  final List<NavigatorObserver> _observers;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  final CurrentNavigators _currentNavigators = const CurrentNavigators();
  final RenewedPage _renewedPage = const RenewedPage();

  /// The root navigator, or `null` while it is not mounted.
  NavigatorState? get navigator => _navigatorKey.currentState;

  @override
  void addListener(VoidCallback listener) => _controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _controller.removeListener(listener);

  @override
  Widget build(BuildContext context) => TypedRouterScope(
    // Above the redirects' context: a redirect finds the router through it.
    router: _router,
    child: RedirectScope(
      key: ObjectKey(_router),
      mount: _mount,
      recheckWhileBuilding: _recheck.recheckWhileBuilding,
      // Reads the state on every build: a re-check while building shows in the
      // same frame.
      builder: (context) => _withHeroes(
        context.getInheritedWidgetOfExactType<HeroControllerScope>(),
        NavigationStateScope(
          state: _controller.state,
          child: Navigator(
            key: _navigatorKey,
            pages: _pages.pagesFor(
              _controller.state,
              onDidRemovePage: _removePage,
            ),
            onDidRemovePage: _removePage,
            observers: _observers,
          ),
        ),
      ),
    ),
  );

  /// [navigator] with the app's hero controller, read once and without a
  /// dependency: the flight path stays fixed, and replacing the controller must
  /// not re-run the redirects. The app's controller stands above the root
  /// navigator, which hides it from the navigators inside; without one, the
  /// root navigator gets its own. `HeroControllerScope. none` is the app's
  /// choice, and stays.
  Widget _withHeroes(HeroControllerScope? appScope, Widget navigator) =>
      HeroFlightScope(
        createRectTween: appScope?.controller?.createRectTween,
        child: appScope == null
            ? NavigatorHeroController(child: navigator)
            : navigator,
      );

  /// A page some navigator popped by itself (back in an app bar, a swipe, a
  /// predictive back gesture, `Navigator.pop`):; in a shell's or a branch's
  /// navigator. A page in a branch not on screen leaves its kept stack. A pop
  /// that would leave nothing on screen brings the page back, made anew. After
  /// dispose the router no longer answers for the screen.
  void _removePage(Page<Object?> page) {
    if (_controller.isDisposed) return;
    final state = _controller.state;
    final removed = _pages.entriesOf(page, state);
    if (removed.isEmpty) return;
    _controller.applyExternalChange(
      state.entries.every(removed.contains)
          ? _renewedPage.renewing(state, page.key, removed)
          : state.withoutEntries(removed),
    );
  }

  /// The system back button: `maybePop` on the current navigators, the deepest
  /// first, until one handles it, as go_router's `_findCurrentNavigators`. A
  /// dialog closes first and `PopScope` can refuse, as with the native
  /// navigator; a page inside a level closes without asking the level's frame
  /// (its `PopScope`), and a drawer or a local history entry inside closes
  /// first. `false` lets the platform close the app.
  @override
  Future<bool> popRoute() async {
    final root = navigator;
    if (root == null) return false;
    for (final current in _currentNavigators.deepestFirst(
      root,
      _controller.state,
    )) {
      if (await current.maybePop()) return true;
    }
    return false;
  }

  /// Not called: the router has no route information parser; it does not
  /// read URLs.
  @override
  Future<void> setNewRoutePath(Object configuration) => SynchronousFuture(null);
}
