part of 'shell_level.dart';

/// One branch of a [TabsEntry] on the stack: a level of its own with its
/// navigator. The tabs make it once per branch.
class BranchEntry extends ShellLevel {
  BranchEntry._(this.tabs, this.branchType);

  /// The tabs instance this branch belongs to.
  final TabsEntry tabs;

  /// The type naming the branch.
  final Type branchType;

  @override
  NavigatorSlot? get slot => tabs.node.branchOf(branchType).navigatorSlot;

  @override
  bool isInstanceOf(Nesting nesting) =>
      nesting is BranchNesting &&
      identical(nesting.node, tabs.node) &&
      nesting.branch == branchType;

  @override
  ShellLevel? takenOverFor(Nesting nesting) => switch (nesting) {
    BranchNesting(:final node, :final branch) when identical(node, tabs.node) =>
      tabs.branch(branch),
    _ => null,
  };

  @override
  String toString() => 'BranchEntry($branchType)';
}
