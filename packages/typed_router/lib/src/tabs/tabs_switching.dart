import 'package:typed_router/src/operation/stack_operations.dart';
import 'package:typed_router/src/state/shell_level.dart';
import 'package:typed_router/src/tabs/branch_switching.dart';

/// Switches the branches of one tabs instance through the router's stack
/// operations, so a switch is a navigation with redirects.
class TabsSwitching implements BranchSwitching {
  /// Creates the switching of [_tabs] through [_operations].
  const TabsSwitching(this._operations, this._tabs);

  final StackOperations _operations;
  final TabsEntry _tabs;

  @override
  void goBranch(Type branch) => _operations.goBranch(_tabs, branch);

  @override
  void resetBranch(Type branch) => _operations.resetBranch(_tabs, branch);
}
