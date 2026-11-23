import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/tree/tree_node.dart';

/// How a route is nested in the tree: inside a shell, or inside one branch of
/// tabs. Each nesting gives the route a navigator of its own on the stack. A
/// value: two nestings are equal when they name the same node (and branch).
sealed class Nesting {
  const Nesting();

  /// Runs the level's redirect for [target]; `null` lets it through.
  TypedRoute<Object?>? redirectFor(
    BuildContext context,
    NavigationState target,
  );
}

/// Nesting inside a [ShellNode].
class ShellNesting extends Nesting {
  /// Creates the nesting inside [node].
  const ShellNesting(this.node);

  /// The shell.
  final ShellNode<Object?> node;

  @override
  TypedRoute<Object?>? redirectFor(
    BuildContext context,
    NavigationState target,
  ) => node.redirectFor(context, target);

  @override
  bool operator ==(Object other) =>
      other is ShellNesting && identical(other.node, node);

  @override
  int get hashCode => identityHashCode(node);

  @override
  String toString() => 'ShellNesting(${identityHashCode(node)})';
}

/// Nesting inside one branch of a [StatefulShellNode].
class BranchNesting extends Nesting {
  /// Creates the nesting inside [branch] of [node].
  const BranchNesting(this.node, this.branch);

  /// The tabs node.
  final StatefulShellNode node;

  /// The type naming the branch.
  final Type branch;

  @override
  TypedRoute<Object?>? redirectFor(
    BuildContext context,
    NavigationState target,
  ) => node.redirectFor(context, target);

  @override
  bool operator ==(Object other) =>
      other is BranchNesting &&
      identical(other.node, node) &&
      other.branch == branch;

  @override
  int get hashCode => Object.hash(identityHashCode(node), branch);

  @override
  String toString() => 'BranchNesting($branch)';
}
