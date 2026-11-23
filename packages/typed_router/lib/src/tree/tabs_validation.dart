import 'package:typed_router/src/tree/nesting.dart';
import 'package:typed_router/src/tree/route_registry.dart';
import 'package:typed_router/src/tree/tree_node.dart';

// A node without a name is named by its route type (a branch by its type)
// in these messages; type names are readable in debug builds, where these
// errors are met.
// ignore_for_file: avoid_type_to_string

/// The checks of a [StatefulShellNode] when the router is built: each fails
/// with an [ArgumentError] that says how to fix it.
class TabsValidation {
  /// Creates the checks.
  const TabsValidation();

  /// The tabs have branches, each with its own type and some children.
  void checkBranches(StatefulShellNode tabs) {
    if (tabs.branches.isEmpty) {
      throw ArgumentError(
        'A StatefulShellNode has no branches. Give it at least one '
        'BranchNode.',
      );
    }
    final seen = <Type>{};
    for (final branch in tabs.branches) {
      final branchType = branch.branchType;
      // An inferred branch type tells branches apart from nothing, so goBranch
      // cannot reach the branch.
      if (branchType == dynamic || branchType == _AnyObject) {
        throw ArgumentError(
          'A BranchNode has no branch type, so goBranch cannot name it. '
          'Write BranchNode<YourBranch>(...) with a class of its own.',
        );
      }
      if (!seen.add(branchType)) {
        throw ArgumentError(
          'Branch $branchType appears twice in a StatefulShellNode. Give '
          'every branch its own type.',
        );
      }
      if (branch.children.isEmpty) {
        throw ArgumentError(
          'Branch $branchType has no children. Give it at least one node.',
        );
      }
    }
  }

  /// [branch]'s initial route is placed inside [level], once the branch's
  /// children are registered.
  void checkInitial(
    BranchNode<Object?> branch,
    BranchNesting level,
    RouteRegistry registry,
  ) {
    final initial = branch.initial;
    if (!registry.hasNodeFor(initial) ||
        !registry.placementOf(initial).guardingNestings.contains(level)) {
      throw ArgumentError(
        'The initial route $initial of branch ${branch.branchType} is not '
        "in that branch. Use a route of the branch's subtree.",
      );
    }
    // Shown in another navigator, the initial route would take the tabs off
    // screen on goBranch.
    if (!registry.placementOf(initial).nestings.contains(level)) {
      throw ArgumentError(
        'The initial route $initial of branch ${branch.branchType} is shown '
        "outside the branch's navigator (its parentNavigatorSlot). The "
        'first screen of a branch must show inside it.',
      );
    }
  }
}

/// `Object?`, the type an unconstrained `B` can be inferred as.
typedef _AnyObject = Object?;
