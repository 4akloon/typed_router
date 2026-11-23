part of 'tree_node.dart';

/// A branch of a [StatefulShellNode], named by [B]: a type of the app,
/// usually without fields (`HomeBranch`). One tab with its own navigator
/// and stack.
///
/// Not a [TreeNode]: it goes only into [StatefulShellNode.branches], which
/// the compiler checks.
///
/// A feature module may declare a node as a class of its own that extends
/// this one and passes everything to the super constructor. Overriding
/// members is not supported: the router relies on them.
///
/// {@category shells-and-tabs}
class BranchNode<B> {
  /// Creates a branch that starts at [initial].
  const BranchNode({
    required this.initial,
    required this.children,
    this.navigatorSlot,
  });

  /// Names this branch's navigator, so routes below can show in it with
  /// `RouteNode.parentNavigatorSlot`. Optional.
  final NavigatorSlot? navigatorSlot;

  /// The route the branch shows on its first visit and after a reset; it
  /// must be in [children]'s subtree, which the router checks when it is
  /// built.
  final TypedRoute<Object?> initial;

  /// The nodes of the branch. At least one.
  final List<TreeNode<NoParentRoute>> children;

  /// The type naming the branch.
  @internal
  Type get branchType => B;
}
