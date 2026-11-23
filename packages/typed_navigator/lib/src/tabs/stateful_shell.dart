import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:typed_navigator/src/tabs/branch_keep_alive.dart';
import 'package:typed_navigator/src/tabs/branch_switching.dart';

/// The branch navigators of a `StatefulShellNode`, the active one shown,
/// and the way to switch branches; what the tabs' builder frames, like
/// go_router's `StatefulNavigationShell`.
///
/// Switching is a navigation: redirects run, listeners hear about it. A
/// branch not visited yet has no navigator. To reset a branch, as
/// go_router's `goBranch(index, initialLocation: true)`, use
/// [resetBranch] or [resetBranchAt].
///
/// {@category shells-and-tabs}
class StatefulShell extends StatelessWidget {
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

  /// The navigators of the branches in tab order, for a builder that lays them
  /// out itself (a cross-fade, a `PageView`) instead of showing this widget;
  /// go_router's `navigatorContainerBuilder`. A branch not visited yet is an
  /// empty box until [goBranch] visits it.
  ///
  /// The container only lays them out; switching is still [goBranch] /
  /// [goBranchAt], and back and the back gesture go to the branch at
  /// [currentIndex] whatever the container shows. A scrolling container
  /// must follow the shell both ways: start at [currentIndex], move when
  /// it changes, and call [goBranchAt] when the user scrolls
  /// (`PageView(onPageChanged: shell.goBranchAt)`).
  ///
  /// Put each navigator in the tree exactly once (it has a global key):
  /// either this widget or these navigators, not both. Keep a hidden one in
  /// the tree, or its screens lose their state. Hiding is the container's
  /// job: `TickerMode`, focus, hit testing and semantics, as this widget's
  /// own `IndexedStack` does. Each comes kept alive for scrolling
  /// containers.
  List<Widget> get navigators => [
    for (final branch in branches)
      BranchKeepAlive(
        key: ValueKey(branch),
        child: _navigators[branch] ?? const SizedBox.shrink(),
      ),
  ];

  /// The branch navigators in an `IndexedStack`; a branch not on screen stops
  /// ticking (`TickerMode`), as go_router's default container does.
  @override
  Widget build(BuildContext context) => IndexedStack(
    index: currentIndex,
    children: [
      for (final (index, navigator) in navigators.indexed)
        TickerMode(enabled: index == currentIndex, child: navigator),
    ],
  );
}
