import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:typed_navigator/src/page/page_factory.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/tabs/stateful_shell.dart';
import 'package:typed_navigator/src/tree/no_parent_route.dart';

part 'branch_node.dart';
part 'shell_node.dart';
part 'stateful_shell_node.dart';

// TreeNode is sealed, so its variants live in this library. The functions a
// node holds are only called from the node's own methods, where the route
// type is known: read through a wider type they would fail Dart's covariance
// check at runtime.

/// A node of the route tree, declared top-down.
///
/// [P] is the type of the route directly above the node. A node that needs
/// nothing from above is a `TreeNode<NoParentRoute>`; a node that builds its
/// parent route ([RouteNode.withParent]) is a `TreeNode<ThatParentRoute>`, so
/// the compiler only lets it sit under that parent.
sealed class TreeNode<P> {
  const TreeNode();
}

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
  });

  /// Builds the screen for a route of type [R].
  final Widget Function(BuildContext context, R route) build;

  /// Nodes under this one. Each of them is put here with [withParent], so it
  /// can build an [R] for the stack below itself.
  final List<TreeNode<R>> children;

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

/// A [RouteNode] put under a parent route with [RouteNode.withParent].
///
/// Not exported: users only ever see it as a `TreeNode<P>`.
final class ParentedRouteNode<
  P extends TypedRoute<Object?>,
  R extends TypedRoute<Object?>
>
    extends TreeNode<P> {
  /// Wraps [node] with the function that builds its parent route.
  const ParentedRouteNode(this.node, this._buildParent);

  /// The node placed under the parent.
  final RouteNode<R> node;

  final P Function(R route) _buildParent;

  /// Builds the parent route of [route], which is always an [R].
  TypedRoute<Object?> buildParent(TypedRoute<Object?> route) =>
      _buildParent(route as R);
}
