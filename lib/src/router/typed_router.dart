import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:typed_navigator/src/operation/stack_operations.dart';
import 'package:typed_navigator/src/page/navigator_pages.dart';
import 'package:typed_navigator/src/page/page_factory.dart';
import 'package:typed_navigator/src/redirect/router_mount.dart';
import 'package:typed_navigator/src/redirect/stack_recheck.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/router/router_parts.dart';
import 'package:typed_navigator/src/router/typed_router_delegate.dart';
import 'package:typed_navigator/src/router/typed_router_scope.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/transaction/navigation_controller.dart';
import 'package:typed_navigator/src/tree/no_parent_route.dart';
import 'package:typed_navigator/src/tree/tree_node.dart';

/// The application's router: owns the route tree and the current
/// [NavigationState], shows it in the root navigator and notifies
/// listeners when it changes.
///
/// Create it once, before `runApp`, keep it where the app keeps its
/// dependencies (a top-level `final`, a DI container) and pass it to
/// `MaterialApp.router(routerConfig: router)`. The library has no global
/// access to routers; several independent routers can live in one process.
/// The creator calls [dispose]; widgets never dispose it.
///
/// ```dart
/// final router = TypedRouter(
///   routes: [
///     RouteNode<RoomsRoute>(
///       build: (context, route) => const RoomsScreen(),
///       children: [
///         RouteNode<RoomRoute>(
///           build: (context, route) => RoomScreen(id: route.id),
///         ).withParent((room) => const RoomsRoute()),
///       ],
///     ),
///   ],
///   initialRoute: const RoomsRoute(),
///   pageFactory: const MaterialPageFactory(),
///   redirect: (context, target) => session.isBanned ? const BannedRoute() : null,
///   refreshListenable: session,
/// );
/// ```
final class TypedRouter implements RouterConfig<Object>, Listenable {
  /// Creates a router over the tree of [routes] that starts at
  /// [initialRoute], with the routes above it built from the tree.
  /// [pageFactory] turns every screen into a [Page] unless the route's node
  /// has its own factory.
  ///
  /// Redirects, as in go_router: [redirect] runs first for every navigation
  /// the router checks, then the `redirect`s of the nodes (see
  /// [RouteNode.redirect]); each returns the route to go to instead, or
  /// `null` to let the navigation through. They get the context of the
  /// `Router` showing this router and run only while it is shown: a
  /// navigation before `runApp` is checked when the router is first shown.
  /// [refreshListenable] and [refresh] re-check the whole stack. A chain of
  /// more than [redirectLimit] redirects, or a loop, is a
  /// [RedirectChainError]. When the redirects fail while the router is
  /// shown for the first time or re-checks the stack, the navigator shows
  /// [errorBuilder]'s screen (a plain one without it) and [state] carries
  /// the error.
  ///
  /// Needs no widgets binding. Throws [ArgumentError] when [routes] is
  /// empty, a route type has two nodes, [initialRoute]'s type has no node,
  /// or [redirectLimit] is negative.
  factory TypedRouter({
    required List<TreeNode<NoParentRoute>> routes,
    required TypedRoute<Object?> initialRoute,
    required PageFactory pageFactory,
    TypedRoute<Object?>? Function(BuildContext context, NavigationState target)?
    redirect,
    Listenable? refreshListenable,
    int redirectLimit = 5,
    Widget Function(BuildContext context, Object error)? errorBuilder,
  }) => TypedRouter._(
    RouterParts(
      routes: routes,
      initialRoute: initialRoute,
      pageFactory: pageFactory,
      redirect: redirect,
      redirectLimit: redirectLimit,
      errorBuilder: errorBuilder,
    ),
    refreshListenable,
  );

  TypedRouter._(RouterParts parts, this._refreshListenable)
    : _controller = parts.controller,
      _operations = parts.operations,
      _recheck = parts.recheck,
      _pages = parts.pages,
      _mount = parts.mount {
    _refreshListenable?.addListener(_recheck.recheck);
  }

  final NavigationController _controller;
  final StackOperations _operations;
  final StackRecheck _recheck;
  final NavigatorPages _pages;
  final RouterMount _mount;
  final Listenable? _refreshListenable;
  final BackButtonDispatcher _backButtonDispatcher = RootBackButtonDispatcher();
  late final TypedRouterDelegate _delegate = TypedRouterDelegate(
    router: this,
    controller: _controller,
    pages: _pages,
    mount: _mount,
    recheck: _recheck,
  );

  /// The router of the `MaterialApp.router` (or `WidgetsApp.router`) above
  /// [context]: from a screen or a dialog of its navigator.
  ///
  /// Does not rebuild [context] on navigation; listen to the router for
  /// that. Throws [FlutterError] when there is no router above.
  static TypedRouter of(BuildContext context) =>
      TypedRouterScope.routerOf(context);

  /// What is on screen now. Starts at the initial route and its ancestors;
  /// stays readable after [dispose].
  ///
  /// Before the router is first shown, it is the requested state: the
  /// redirects check it when the router is shown.
  NavigationState get state => _controller.state;

  /// Replaces the stack with [route] and the routes above it in the tree.
  /// Entries of the common prefix that hold equal routes stay, with their
  /// screens' state; the pushes of removed entries complete with `null`.
  void go(TypedRoute<Object?> route) => _operations.go(route);

  /// Puts [route] on top as a new entry, without its ancestors. Completes
  /// with the result the page is popped with ([pop] or a native
  /// `Navigator.pop(context, result)`), or `null` when it leaves another
  /// way. Throws [ArgumentError] when [route]'s type has no node.
  Future<T?> push<T>(TypedRoute<T> route) => _operations.push(route);

  /// Removes the top entry and completes its [push] with [result].
  ///
  /// Throws [StateError] on the last entry (see [canPop]) and
  /// [ArgumentError] when the top route's [push] awaits another type.
  @optionalTypeArgs
  void pop<T>([T? result]) => _operations.pop(result);

  /// Whether [pop] can remove an entry: the stack has more than one, and
  /// the error screen is not shown.
  bool get canPop => _operations.canPop;

  /// Removes entries from the top until [predicate] holds for the top
  /// route; throws [StateError] and changes nothing when none matches.
  void popUntil(bool Function(TypedRoute<Object?> route) predicate) =>
      _operations.popUntil(predicate);

  /// Replaces the top entry with [route]; the replaced push completes with
  /// `null`. Returns the push of [route], as [push] does.
  Future<T?> replace<T>(TypedRoute<T> route) => _operations.replace(route);

  /// [popUntil] [predicate], then [push] [route], as one navigation.
  Future<T?> pushAndRemoveUntil<T>(
    TypedRoute<T> route,
    bool Function(TypedRoute<Object?> route) predicate,
  ) => _operations.pushAndRemoveUntil(route, predicate);

  /// The state [go] would build for [route], before redirects; for
  /// `TypedRouterTargets` in `testing.dart`.
  @internal
  NavigationState plannedGo(TypedRoute<Object?> route) =>
      _operations.plannedGo(route);

  /// The state [push] would build for [route], before redirects; for
  /// `TypedRouterTargets` in `testing.dart`.
  @internal
  NavigationState plannedPush(TypedRoute<Object?> route) =>
      _operations.plannedPush(route);

  /// Runs the redirects over the whole stack, as a notification of
  /// `refreshListenable` does: if one redirects, the stack becomes its
  /// target with the routes above it. Does nothing while the router is not
  /// shown.
  void refresh() => _recheck.recheck();

  /// The root navigator, or `null` while the router is not mounted in a
  /// widget tree. For code outside the widget tree that shows dialogs or
  /// overlays: `router.navigator?.overlay`.
  NavigatorState? get navigator => _delegate.navigator;

  /// For [Router]; not meant to be called by the app.
  @override
  RouterDelegate<Object> get routerDelegate => _delegate;

  /// `null` until URLs (0.5).
  @override
  RouteInformationParser<Object>? get routeInformationParser => null;

  /// `null` until URLs (0.5).
  @override
  RouteInformationProvider? get routeInformationProvider => null;

  /// Sends the platform's back button to the root navigator's `maybePop`:
  /// a dialog closes first, `PopScope` can block, then the top page leaves;
  /// on the first page the platform closes the app.
  @override
  BackButtonDispatcher get backButtonDispatcher => _backButtonDispatcher;

  /// Calls [listener] after every navigation that changes [state].
  ///
  /// Throws [StateError] after [dispose].
  @override
  void addListener(VoidCallback listener) => _controller.addListener(listener);

  /// Stops calling [listener]. Allowed after [dispose], so a widget can
  /// clean up after the router is gone.
  @override
  void removeListener(VoidCallback listener) =>
      _controller.removeListener(listener);

  /// Releases the router: stops listening to `refreshListenable`, drops
  /// the listeners and ends every route on the stack.
  ///
  /// [state] stays readable; adding a listener, navigating or disposing
  /// again throws [StateError].
  void dispose() {
    _refreshListenable?.removeListener(_recheck.recheck);
    _controller.dispose();
  }

  /// `TypedRouter(RoomsRoute() > RoomRoute(RoomId(7)))`, for logs and test
  /// failures.
  @override
  String toString() => 'TypedRouter($state)';
}
