part of 'tree_node.dart';

/// Tabs: a shell whose branches each keep their own navigator and stack,
/// like go_router's `StatefulShellRoute`. Branches are named by types
/// ([BranchNode]), never by index.
///
/// The builder frames [StatefulShell], which shows the active branch and
/// switches branches. A branch is built when it is first visited and keeps
/// its stack while another one is shown. `go` to a route of another branch
/// switches to it; `push` goes into the active branch.
///
/// The children of the branches start their own chains: the tabs pass no
/// parent route down, and they fit anywhere in the tree.
///
/// ```dart
/// StatefulShellNode(
///   builder: (context, state, shell) => Scaffold(
///     body: shell,
///     bottomNavigationBar: NavigationBar(
///       selectedIndex: shell.currentIndex,
///       onDestinationSelected: (index) => index == shell.currentIndex
///           ? shell.resetBranchAt(index)
///           : shell.goBranchAt(index),
///       destinations: const [...],
///     ),
///   ),
///   branches: [
///     BranchNode<HomeBranch>(initial: const HomeRoute(), children: [...]),
///     BranchNode<RoomsBranch>(initial: const RoomsRoute(), children: [...]),
///   ],
/// )
/// ```
final class StatefulShellNode extends TreeNode<NoParentRoute> {
  /// Creates tabs with [branches]; the router throws [ArgumentError] when
  /// there is none, a branch type repeats, a branch is empty or its
  /// initial route is not in it.
  const StatefulShellNode({
    required this.builder,
    required this.branches,
    this.pageFactory,
    this.redirect,
  });

  /// Builds the frame (a navigation bar, a rail) around [shell]. Rebuilt
  /// on every navigation; [state] is the router's whole state.
  final Widget Function(
    BuildContext context,
    NavigationState state,
    StatefulShell shell,
  )
  builder;

  /// The branches, in the order of their tabs. At least one.
  final List<BranchNode<Object?>> branches;

  /// Makes the page of the tabs; the router's factory when `null`.
  final PageFactory? pageFactory;

  /// Sends a navigation elsewhere before it shows a route of any branch;
  /// runs before the redirects of the nodes in the branch, like
  /// [ShellNode.redirect].
  final TypedRoute<Object?>? Function(
    BuildContext context,
    NavigationState target,
  )?
  redirect;

  /// The branch types, in tab order.
  @internal
  List<Type> get branchTypes => [
    for (final branch in branches) branch.branchType,
  ];

  /// The branch named [branchType]; throws [ArgumentError] for another
  /// type.
  @internal
  BranchNode<Object?> branchOf(Type branchType) => branches.firstWhere(
    (branch) => branch.branchType == branchType,
    orElse: () => throw ArgumentError.value(
      branchType,
      'branch',
      'Not a branch of these tabs.',
    ),
  );

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
