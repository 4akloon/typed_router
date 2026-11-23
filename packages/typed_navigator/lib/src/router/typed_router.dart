import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/operation/stack_operations.dart';
import 'package:typed_navigator/src/page/navigator_observers.dart';
import 'package:typed_navigator/src/page/navigator_pages.dart';
import 'package:typed_navigator/src/page/page_factory.dart';
import 'package:typed_navigator/src/redirect/router_mount.dart';
import 'package:typed_navigator/src/redirect/stack_recheck.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/router/router_parts.dart';
import 'package:typed_navigator/src/router/slot_navigators.dart';
import 'package:typed_navigator/src/router/top_route_pop.dart';
import 'package:typed_navigator/src/router/typed_router_delegate.dart';
import 'package:typed_navigator/src/router/typed_router_scope.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/transaction/navigation_controller.dart';
import 'package:typed_navigator/src/tree/navigator_slot.dart';
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
///   // The app's own factory: see PageFactory.
///   pageFactory: const MaterialPageFactory(),
///   redirect: (context, target) => session.isBanned ? const BannedRoute() : null,
///   refreshListenable: session,
/// );
/// ```
///
/// Operations change [state] at once; the navigator shows it in the next frame,
/// as a declarative `Navigator` does. Unlike `Navigator.push`, a dialog shown
/// or a `Navigator.pop` called in the same callback as an operation reaches the
/// old page (go_router has the same, flutter/flutter#146578). Take the
/// navigator first and wait for the frame:
///
/// ```dart
/// final navigator = Navigator.of(context);
/// router.push(const RoomRoute(RoomId(7)));
/// WidgetsBinding.instance.addPostFrameCallback(
///   (_) => showDialog(context: navigator.context, builder: buildWelcome),
/// );
/// ```
class TypedRouter implements RouterConfig<Object>, Listenable {
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
  /// [observers] observe the root navigator and, as go_router's do, the
  /// navigators of shells and tabs branches too (Sentry, analytics); for
  /// every event their `navigator` is the root one. Pages carry their
  /// node's `RouteNode.name`. For typed events, listen to the router itself
  /// and read [state].
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
    List<NavigatorObserver> observers = const [],
  }) => TypedRouter._(
    RouterParts(
      routes: routes,
      initialRoute: initialRoute,
      pageFactory: pageFactory,
      redirect: redirect,
      redirectLimit: redirectLimit,
      errorBuilder: errorBuilder,
      observers: observers,
    ),
    refreshListenable,
  );

  TypedRouter._(RouterParts parts, this._refreshListenable)
    : _controller = parts.controller,
      _operations = parts.operations,
      _recheck = parts.recheck,
      _pages = parts.pages,
      _mount = parts.mount,
      _observers = parts.observers {
    _refreshListenable?.addListener(_recheck.recheck);
  }

  final NavigationController _controller;
  final StackOperations _operations;
  final StackRecheck _recheck;
  final NavigatorPages _pages;
  final NavigatorObservers _observers;
  final RouterMount _mount;
  final Listenable? _refreshListenable;
  final BackButtonDispatcher _backButtonDispatcher = RootBackButtonDispatcher();
  final SlotNavigators _slotNavigators = const SlotNavigators();
  late final TopRoutePop _topRoutePop = TopRoutePop(
    () => _delegate.navigator,
    _operations,
    () => _controller.state,
  );
  late final TypedRouterDelegate _delegate = TypedRouterDelegate(
    router: this,
    controller: _controller,
    pages: _pages,
    mount: _mount,
    recheck: _recheck,
    observers: _observers.root,
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

  /// Replaces the stack with [route] and the routes above it in the tree;
  /// shown in the next frame (a dialog after it: see [TypedRouter]).
  /// Entries of the common prefix that hold equal routes stay, with their
  /// screens' state; the pushes of removed entries complete with `null`.
  void go(TypedRoute<Object?> route) => _operations.go(route);

  /// Puts [route] on top as a new entry, without its ancestors, shown in
  /// the next frame (a dialog after it: see [TypedRouter]). In tabs on
  /// screen, a route of another tab goes into the active one, as with
  /// go_router. Completes
  /// with the result the page is popped with ([pop] or a native
  /// `Navigator.pop(context, result)`), or `null` when it leaves another
  /// way. Throws [ArgumentError] when [route]'s type has no node.
  Future<T?> push<T>(TypedRoute<T> route) => _operations.push(route);

  /// Closes the top route, as `Navigator.pop` and go_router's `pop`: a
  /// dialog (or another route pushed without a page) above the top page
  /// closes first, with [result]; else the top entry leaves and its [push]
  /// completes with [result]. The deepest navigator on screen that can pop
  /// goes first: a dialog in a shell's navigator too. `PopScope` is not
  /// asked, as with `Navigator.pop`.
  ///
  /// Throws [StateError] when nothing can close (see [canPop]) and
  /// [ArgumentError] when the top route's [push] awaits another type.
  @optionalTypeArgs
  void pop<T>([T? result]) => _topRoutePop.pop(result);

  /// Whether [pop] can close something: a dialog on screen, or a page above
  /// another while the error screen is not shown.
  bool get canPop => _topRoutePop.canPop;

  /// Removes entries from the top until [predicate] holds for the top
  /// route; throws [StateError] and changes nothing when none matches.
  void popUntil(bool Function(TypedRoute<Object?> route) predicate) =>
      _operations.popUntil(predicate);

  /// Shows [route] in the top page, updated in place, as go_router's
  /// `replace`: the same page, no transition, and the screen keeps its
  /// state (give the screen `key: ValueKey(route)` for a fresh one). When
  /// [route] stands in other levels or its node makes another kind of page,
  /// it gets a new page, as with [pushReplacement]. The replaced push
  /// completes with `null`. Returns the push of [route], as [push] does.
  ///
  /// The navigator only updates the page, so its observers hear nothing,
  /// as with go_router's `replace`; the router's listeners hear the change
  /// (`Navigator.replace` tells observers `didReplace`). With nothing below
  /// the top entry, [route] and the routes above it come, as [go].
  Future<T?> replace<T>(TypedRoute<T> route) => _operations.replace(route);

  /// Shows [route] in a new page in place of the top one, with a
  /// transition, as `Navigator.pushReplacement`; the replaced push completes
  /// with `null`. Returns the push of [route], as [push] does.
  Future<T?> pushReplacement<T>(TypedRoute<T> route) =>
      _operations.pushReplacement(route);

  /// [popUntil] [predicate], then [push] [route], as one navigation. When
  /// [predicate] holds for no route, [route] stays alone, as with
  /// `Navigator.pushAndRemoveUntil` (where [popUntil] throws).
  Future<T?> pushAndRemoveUntil<T>(
    TypedRoute<T> route,
    bool Function(TypedRoute<Object?> route) predicate,
  ) => _operations.pushAndRemoveUntil(route, predicate);

  /// The state `go(route)` would build from the current state: [route]
  /// with the routes above it, as the target a redirect receives.
  ///
  /// For calling a redirect on its own in a test, as go_router tests build
  /// a `GoRouterState`. Most redirect tests go through the app instead:
  /// show the router, change the session fake, read [state]. Runs no
  /// redirects, commits nothing and works before the router is shown.
  /// Throws [ArgumentError] when [route]'s type has no node.
  ///
  /// ```dart
  /// final target = router.stateAfterGo(const AccountRoute());
  /// final context = tester.element(find.byType(HomeScreen));
  ///
  /// expect(
  ///   appRedirect(context, target),
  ///   const SignInRoute(returnTo: AccountRoute()),
  /// );
  /// ```
  ///
  /// Experimental until 1.0: it may change without a major version.
  @visibleForTesting
  NavigationState stateAfterGo(TypedRoute<Object?> route) =>
      _operations.plannedGo(route);

  /// The state `push(route)` would build: the current stack with [route]
  /// on top, as the target a redirect receives.
  ///
  /// The [push] counterpart of [stateAfterGo]; the same rules apply.
  /// Throws [ArgumentError] when [route]'s type has no node.
  @visibleForTesting
  NavigationState stateAfterPush(TypedRoute<Object?> route) =>
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

  /// The navigator of [slot] (a `ShellNode`'s or `BranchNode`'s
  /// `navigatorSlot`) on the active path, nearest the top: for code outside
  /// the shell's widgets that shows a dialog in it, as go_router apps use a
  /// shell's navigator key. [NavigatorSlot.root] gives [navigator]. `null`
  /// while the router is not shown, or when no shell of [slot] is on the
  /// active path. Inside the shell, `Navigator.of(context)` is that
  /// navigator already.
  ///
  /// ```dart
  /// final navigator = router.navigatorOf(roomsSlot);
  /// if (navigator != null) showDialog(context: navigator.context, ...);
  /// ```
  NavigatorState? navigatorOf(NavigatorSlot slot) =>
      _slotNavigators.of(slot, navigator, _controller.state);

  /// For [Router]; not meant to be called by the app.
  @override
  RouterDelegate<Object> get routerDelegate => _delegate;

  /// `null`: the router neither reads nor reports URLs; routes are
  /// values, and the app turns its own links into `go` or `push`.
  @override
  RouteInformationParser<Object>? get routeInformationParser => null;

  /// `null`: the router neither reads nor reports URLs.
  @override
  RouteInformationProvider? get routeInformationProvider => null;

  /// Sends the platform's back button to `maybePop` of the current
  /// navigators, the deepest shell or branch first: a dialog closes first,
  /// `PopScope` can block, then the top page leaves; on the first page the
  /// platform closes the app.
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
