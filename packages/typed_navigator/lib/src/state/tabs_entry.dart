part of 'shell_level.dart';

/// One instance of tabs on the stack, with one [BranchEntry] per branch, made
/// once: a branch of this instance is always the same level and the same
/// navigator.
///
/// Compared by identity.
class TabsEntry {
  /// Creates a new instance of [node] and its branches.
  TabsEntry(this.node) : branchTypes = List.unmodifiable(node.branchTypes) {
    for (final branchType in branchTypes) {
      _branches[branchType] = BranchEntry._(this, branchType);
    }
  }

  /// The node this instance shows.
  final StatefulShellNode node;

  /// The branch types, in tab order.
  final List<Type> branchTypes;

  final Map<Type, BranchEntry> _branches = {};

  /// The level of [branchType]; throws [ArgumentError] for a type that is
  /// not a branch of these tabs.
  BranchEntry branch(Type branchType) =>
      _branches[branchType] ??
      (throw ArgumentError.value(
        branchType,
        'branch',
        'Not a branch of these tabs. Pass one of $branchTypes.',
      ));

  @override
  String toString() => 'TabsEntry(${identityHashCode(this)})';
}
