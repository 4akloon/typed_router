import 'package:flutter/material.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/scenarios/tab_branches.dart';
import 'package:typed_navigator_example/scenarios/tabs_navigation_bar.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const tabsPageViewScenario = Scenario(
  title: 'Tabs in a PageView',
  summary: 'shell.navigators laid out by the app\'s own container.',
  instructions: [
    'Swipe between the tabs, or tap the bar: the PageView and the shell '
        'follow each other (onPageChanged: shell.goBranchAt).',
    'A tab not visited yet is empty until the swipe passes half way.',
    'Stacks and counters are kept, as with the default container; back '
        'goes to the tab on screen. Tabs off screen stop ticking and take no '
        'focus: hiding them is the container\'s job.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () => TypedRouter(
    routes: [
      StatefulShellNode(
        builder: (context, state, shell) => Scaffold(
          body: _PagedBranches(shell),
          bottomNavigationBar: TabsNavigationBar(shell),
        ),
        branches: tabBranches(),
      ),
    ],
    initialRoute: const RoomsRoute(),
    pageFactory: const MaterialPageFactory(),
  ),
);

/// The branch navigators in a [PageView] that follows the shell both ways.
final class _PagedBranches extends StatefulWidget {
  const _PagedBranches(this.shell);

  final StatefulShell shell;

  @override
  State<_PagedBranches> createState() => _PagedBranchesState();
}

final class _PagedBranchesState extends State<_PagedBranches> {
  late final PageController _pages = PageController(
    initialPage: widget.shell.currentIndex,
  );

  /// The branch the view shows or scrolls to.
  late int _targetIndex;

  /// Counts the scrolls to the shell's branch: while the latest runs, the
  /// pages it passes are not switches of the user.
  int _follows = 0;
  bool _isFollowingShell = false;

  @override
  void initState() {
    super.initState();
    _targetIndex = widget.shell.currentIndex;
  }

  @override
  void didUpdateWidget(_PagedBranches oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = widget.shell.currentIndex;
    if (index != _targetIndex && _pages.hasClients) _follow(index);
  }

  Future<void> _follow(int index) async {
    _targetIndex = index;
    final follow = ++_follows;
    _isFollowingShell = true;
    await _pages.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (follow == _follows) _isFollowingShell = false;
  }

  void _onPageChanged(int index) {
    if (_isFollowingShell) return;
    _targetIndex = index;
    widget.shell.goBranchAt(index);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageView(
    controller: _pages,
    onPageChanged: _onPageChanged,
    children: [
      // Hiding a branch is the container's job (StatefulShell.navigators).
      for (final (index, navigator) in widget.shell.navigators.indexed)
        TickerMode(
          enabled: index == widget.shell.currentIndex,
          child: ExcludeFocus(
            excluding: index != widget.shell.currentIndex,
            child: navigator,
          ),
        ),
    ],
  );
}
