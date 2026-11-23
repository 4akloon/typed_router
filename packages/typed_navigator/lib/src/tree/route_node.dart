part of 'tree_node.dart';

/// Places routes of type [R] in the tree and builds their screen.
///
/// A route type has exactly one node. To show the same screen in another
/// place, declare a separate route type.
///
/// ```dart
/// final List<TreeNode<NoParentRoute>> roomsRoutes = [
///   RouteNode<RoomsRoute>(
///     build: (context, route) => const RoomsPage(),
///     children: [
///       RouteNode<RoomRoute>(
///         build: (context, room) => RoomPage(roomId: room.id),
///       ).withParent((_) => const RoomsRoute()),
///     ],
///   ),
/// ];
/// ```
///
/// A feature module may declare a node as a class of its own that extends
/// this one and passes everything to the super constructor. Overriding
/// members is not supported: the router relies on them.
class RouteNode<R extends TypedRoute<Object?>> extends TreeNode<NoParentRoute> {
  /// Creates a node for routes of type [R].
  const RouteNode({
    required this.build,
    this.children = const [],
    this.pageFactory,
    this.redirect,
    this.parentNavigatorSlot,
    this.name,
  });

  /// A stable name for analytics and crash reports: the name of this route's
  /// page (`Page.name`, so `RouteSettings.name` for observers) and of the node
  /// in the router's error messages. Optional: add it where Sentry or analytics
  /// need it. A label, not an address: navigation goes by route values, so
  /// nodes may share a name.
  final String? name;

  /// Builds the screen for a route of type [R].
  final Widget Function(BuildContext context, R route) build;

  /// Nodes under this one. Each of them is put here with [withParent], so it
  /// can build an [R] for the stack below itself.
  final List<TreeNode<R>> children;

  /// The navigator to show this route in, like go_router's
  /// `parentNavigatorKey`: [NavigatorSlot.root], or the slot of a shell or
  /// branch above this node. `null` shows it in the nearest shell or
  /// branch. Children without their own slot stay in the same navigator.
  final NavigatorSlot? parentNavigatorSlot;

  /// Turns this node's screens into pages instead of the router's factory:
  /// a sheet, a dialog or a full-screen modal for this route. `null` uses
  /// the router's factory.
  final PageFactory? pageFactory;

  /// Sends a navigation elsewhere before it shows a route of this node's
  /// subtree: returns the route to go to instead, or `null` to let it
  /// through. Optional.
  ///
  /// It runs for every route of the subtree that a navigation brings in,
  /// including a descendant pushed without this node's route, and for every
  /// one on the stack when the router re-checks it (when it is shown, on
  /// `refreshListenable`, on `TypedRouter.refresh`). [route] is this
  /// node's route for that target: the one on the stack, or the one
  /// `withParent` builds for a descendant. The router's own redirect runs
  /// first, then the nodes from the top of the tree down; the first that
  /// redirects wins. [context] is the context of the `Router` showing the
  /// router; an inherited widget the redirect depends on re-runs it.
  ///
  /// ```dart
  /// RouteNode<RoomsRoute>(
  ///   build: (context, rooms) => const RoomsPage(),
  ///   redirect: (context, rooms, target) =>
  ///       session.isSignedIn ? null : SignInRoute(returnTo: target.top),
  /// )
  /// ```
  final TypedRoute<Object?>? Function(
    BuildContext context,
    R route,
    TypedRouterState target,
  )?
  redirect;

  /// This node under a parent it builds itself from its own route.
  ///
  /// [P] comes from the `children` list the result is put in, so [parent]
  /// must return exactly that parent's route: a wrong type, the wrong place
  /// or the top level do not compile.
  TreeNode<P> withParent<P extends TypedRoute<Object?>>(
    P Function(R route) parent,
  ) => ParentedRouteNode<P, R>(this, parent);

  /// The route type this node places.
  @internal
  Type get routeType => R;

  /// Builds the screen for [route], which is always an [R].
  @internal
  Widget buildScreen(BuildContext context, TypedRoute<Object?> route) =>
      build(context, route as R);

  /// Runs [redirect] for [route], which is always an [R].
  @internal
  TypedRoute<Object?>? redirectFor(
    BuildContext context,
    TypedRoute<Object?> route,
    TypedRouterState target,
  ) => switch (redirect) {
    final redirect? => redirect(context, route as R, target),
    null => null,
  };

  /// This node's [pageFactory], or [routerFactory] when it has none.
  @internal
  PageFactory pageFactoryOr(PageFactory routerFactory) =>
      pageFactory ?? routerFactory;

  /// How errors name this node's page for [route]: its [name], or the
  /// route itself for a node without one.
  @internal
  String describe(TypedRoute<Object?> route) => name ?? '$route';
}
