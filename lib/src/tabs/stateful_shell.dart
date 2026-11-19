import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:typed_navigator/src/tabs/branch_switching.dart';

/// The branch navigators of a `StatefulShellNode`, the active one shown,
/// and the way to switch branches; what the tabs' builder frames, like
/// go_router's `StatefulNavigationShell`.
///
/// Switching is a navigation: redirects run, listeners hear about it. A
/// branch not visited yet has no navigator. To reset a branch, as
/// go_router's `goBranch(index, initialLocation: true)`, use
/// [resetBranch] or [resetBranchAt].
final class StatefulShell extends StatelessWidget {
  /// Created by the router for every build of the tabs.
  @internal
  const StatefulShell({
    required this.branches,
    required this.activeBranch,
    required this._navigators,
    required this._switching,
    super.key,
  });

  /// The branch types, in tab order.
  final List<Type> branches;

  /// The type of the branch on screen.
  final Type activeBranch;

  final Map<Type, Widget> _navigators;
  final BranchSwitching _switching;

  /// The index of [activeBranch] in [branches], for index-based widgets
  /// such as a `NavigationBar`.
  int get currentIndex => branches.indexOf(activeBranch);

  /// Shows branch [B]: its kept stack, or its initial route on the first
  /// visit. Throws [ArgumentError] when [B] is not a branch of these tabs.
  void goBranch<B>() => _switching.goBranch(B);

  /// Shows the branch at [index] in [branches], as [goBranch].
  void goBranchAt(int index) => _switching.goBranch(branches[index]);

  /// Shows branch [B] from its initial route; the pushes of the routes it
  /// drops complete with `null`.
  void resetBranch<B>() => _switching.resetBranch(B);

  /// Resets the branch at [index] in [branches], as [resetBranch].
  void resetBranchAt(int index) => _switching.resetBranch(branches[index]);

  @override
  Widget build(BuildContext context) => IndexedStack(
    index: currentIndex,
    children: [
      for (final branch in branches)
        _navigators[branch] ?? const SizedBox.shrink(),
    ],
  );
}
