/// Switches the branches of one tabs instance on the stack.
///
/// Internal: the router gives one to every `StatefulShell` it builds.
abstract interface class BranchSwitching {
  /// Shows [branch]: its kept stack, or its initial chain on the first
  /// visit.
  void goBranch(Type branch);

  /// Shows [branch] from its initial route, dropping its kept stack.
  void resetBranch(Type branch);
}
