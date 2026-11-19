import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/page_factory.dart';
import 'package:typed_navigator/src/page/page_request.dart';
import 'package:typed_navigator/src/page/route_pages.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/src/tabs/branch_switching.dart';
import 'package:typed_navigator/src/tabs/stateful_shell.dart';

/// Makes the page that holds a nested navigator: a shell's or a tabs instance's
/// with its branch navigators. The page comes from the node's factory or the
/// router's and is keyed by the instance.
final class LevelPages {
  /// Creates the pages with [_routePages] checking the factories, the
  /// router's [_pageFactory] for nodes without their own, and
  /// [_switchingFor] giving each tabs instance its branch switching.
  LevelPages({
    required this._routePages,
    required this._pageFactory,
    required this._switchingFor,
  });

  final RoutePages _routePages;
  final PageFactory _pageFactory;
  final BranchSwitching Function(TabsEntry tabs) _switchingFor;

  /// The page of [shell], whose builder frames [navigator].
  Page<Object?> shellPage(
    ShellEntry shell,
    NavigationState state,
    Widget navigator,
  ) => _routePages.created(
    shell.node.pageFactoryOr(_pageFactory),
    PageRequest(
      key: ObjectKey(shell),
      child: Builder(
        builder: (context) => shell.node.builder(context, state, navigator),
      ),
    ),
    'a shell',
  );

  /// The page of [active]'s tabs: its builder frames a [StatefulShell]
  /// with [navigators], one per visited branch.
  Page<Object?> tabsPage(
    BranchEntry active,
    NavigationState state,
    Map<Type, Widget> navigators,
  ) {
    final tabs = active.tabs;
    final shell = StatefulShell(
      branches: tabs.branchTypes,
      activeBranch: active.branchType,
      navigators: navigators,
      switching: _switchingFor(tabs),
    );
    return _routePages.created(
      tabs.node.pageFactoryOr(_pageFactory),
      PageRequest(
        key: ObjectKey(tabs),
        child: Builder(
          builder: (context) => tabs.node.builder(context, state, shell),
        ),
      ),
      'tabs',
    );
  }
}
