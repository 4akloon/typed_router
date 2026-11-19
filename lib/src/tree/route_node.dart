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
final class RouteNode<R extends TypedRoute<Object?>>
    extends TreeNode<NoParentRoute> {
  /// Creates a node for routes of type [R].
  const RouteNode({
    required this.build,
    this.children = const [],
    this.pageFactory,
    this.redirect,
    this.parentNavigatorSlot,
    this.placeholder,
    this.splitPresentation = SplitPresentation.column,
  });

  /// Builds the screen for a route of type [R].
  final Widget Function(BuildContext context, R route) build;

  /// Nodes under this one. Each of them is put here with [withParent], so it
  /// can build an [R] for the stack below itself.
  final List<TreeNode<R>> children;

  /// The navigator to show this route in, like go_router's
  /// `parentNavigatorKey`: [NavigatorSlot.root], or the slot of a shell, split
  /// or branch above this node. `null` shows it in the nearest shell, split or
  /// branch. Children without their own slot stay in the same navigator.
  final NavigatorSlot? parentNavigatorSlot;

  /// What a [SplitNode] shows in the next column while a route of this node is
  /// the top one: "pick a room" next to the rooms. Not a route: it is not in
  /// the state and has no navigator of its own. `null` lets the top route take
  /// the rest of the width. Ignored outside a split and when the split shows a
  /// stack.
  final Widget Function(BuildContext context, R route)? placeholder;

  /// How a route of this node shows inside a [SplitNode]: a column, or
  /// [SplitPresentation.cover] over the whole split together with every
  /// route above it. Ignored outside a split and when it shows a stack.
  final SplitPresentation splitPresentation;

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
    NavigationState target,
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

  /// The placeholder for [route], which is always an [R], or `null` when
  /// this node has none.
  @internal
  Widget? placeholderOf(TypedRoute<Object?> route) => switch (placeholder) {
    final placeholder? => Builder(
      builder: (context) => placeholder(context, route as R),
    ),
    null => null,
  };

  /// Runs [redirect] for [route], which is always an [R].
  @internal
  TypedRoute<Object?>? redirectFor(
    BuildContext context,
    TypedRoute<Object?> route,
    NavigationState target,
  ) => switch (redirect) {
    final redirect? => redirect(context, route as R, target),
    null => null,
  };

  /// This node's [pageFactory], or [routerFactory] when it has none.
  @internal
  PageFactory pageFactoryOr(PageFactory routerFactory) =>
      pageFactory ?? routerFactory;
}
