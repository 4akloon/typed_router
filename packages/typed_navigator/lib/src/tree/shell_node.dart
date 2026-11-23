part of 'tree_node.dart';

/// A frame with its own navigator around the routes below it, like
/// go_router's `ShellRoute`: a list | detail layout, a flow frame.
///
/// Not a route: it has no value of its own and is not in
/// [NavigationState.routes]. It is transparent for [P]: its children are
/// `TreeNode<P>` and see the same parent route the shell does.
///
/// The children live in the shell's navigator. `go` builds the shell with
/// the chain and keeps the same shell while the navigation stays in it;
/// `push` of a child goes into the shell on screen, or starts a new one
/// when another page covers it. The system back button pops inside the
/// shell first.
///
/// ```dart
/// ShellNode<NoParentRoute>(
///   builder: (context, state, navigator) => ListDetailScaffold(
///     list: UsersPage(selected: state.find<UserRoute>()?.id),
///     detail: navigator,
///   ),
///   children: [
///     RouteNode<UsersRoute>(
///       build: (context, users) => const NoSelection(),
///       children: [
///         RouteNode<UserRoute>(build: (context, user) => UserPage(user.id))
///             .withParent((user) => const UsersRoute()),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// A feature module may declare a node as a class of its own that extends
/// this one and passes everything to the super constructor. Overriding
/// members is not supported: the router relies on them.
class ShellNode<P> extends TreeNode<P> {
  /// Creates a shell around [children]; the router throws [ArgumentError]
  /// when it has none.
  const ShellNode({
    required this.builder,
    required this.children,
    this.pageFactory,
    this.redirect,
    this.navigatorSlot,
  });

  /// Names this shell's navigator, so routes below can show in it with
  /// `RouteNode.parentNavigatorSlot`. Optional.
  final NavigatorSlot? navigatorSlot;

  /// Builds the frame around [navigator]: the shell's own navigator with
  /// the pages of its children. Rebuilt on every navigation; [state] is the
  /// router's whole state.
  final Widget Function(
    BuildContext context,
    NavigationState state,
    Widget navigator,
  )
  builder;

  /// The nodes shown in the shell's navigator. At least one.
  final List<TreeNode<P>> children;

  /// Makes the shell's own page in the navigator around it; the router's
  /// factory when `null`.
  final PageFactory? pageFactory;

  /// Sends a navigation elsewhere before it shows a route of this shell's
  /// subtree; runs before the redirects of the nodes below, like
  /// [RouteNode.redirect]. The shell has no route, so it gets the target
  /// only.
  final TypedRoute<Object?>? Function(
    BuildContext context,
    NavigationState target,
  )?
  redirect;

  /// Runs [redirect] for [target], or lets it through when there is none.
  @internal
  TypedRoute<Object?>? redirectFor(
    BuildContext context,
    NavigationState target,
  ) => redirect?.call(context, target);

  /// This node's [pageFactory], or [routerFactory] when it has none.
  @internal
  PageFactory pageFactoryOr(PageFactory routerFactory) =>
      pageFactory ?? routerFactory;
}
