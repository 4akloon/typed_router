import 'package:flutter/widgets.dart';
import 'package:typed_router/src/page/level_inside.dart';
import 'package:typed_router/src/page/level_pop_gate.dart';
import 'package:typed_router/src/page/page_factory.dart';
import 'package:typed_router/src/page/page_request.dart';
import 'package:typed_router/src/page/route_pages.dart';
import 'package:typed_router/src/router/current_navigators.dart';
import 'package:typed_router/src/state/shell_level.dart';
import 'package:typed_router/src/state/typed_router_state.dart';
import 'package:typed_router/src/tabs/branch_switching.dart';
import 'package:typed_router/src/tabs/stateful_shell.dart';

/// Makes the page that holds a nested navigator: a shell's or a tabs instance's
/// with its branch navigators. The page comes from the node's factory or the
/// router's and is keyed by the instance.
class LevelPages {
  /// Creates the pages with [_routePages] checking the factories, the
  /// router's [_pageFactory] for nodes without their own,
  /// [_switchingFor] giving each tabs instance its branch switching, and
  /// [_currentNavigators] finding the navigators inside a level for back.
  LevelPages({
    required this._routePages,
    required this._pageFactory,
    required this._switchingFor,
    required this._currentNavigators,
  });

  final RoutePages _routePages;
  final PageFactory _pageFactory;
  final BranchSwitching Function(TabsEntry tabs) _switchingFor;
  final CurrentNavigators _currentNavigators;

  /// The page of [shell], whose builder frames [navigator].
  Page<Object?> shellPage(
    ShellEntry shell,
    TypedRouterState state,
    Widget navigator,
  ) => _routePages.created(
    shell.node.pageFactoryOr(_pageFactory),
    PageRequest(
      key: ObjectKey(shell),
      child: _gated(
        shell,
        state,
        Builder(
          builder: (context) => shell.node.builder(context, state, navigator),
        ),
      ),
    ),
    'a shell',
  );

  /// The page of [active]'s tabs: its builder frames a [StatefulShell]
  /// with [navigators], one per visited branch.
  Page<Object?> tabsPage(
    BranchEntry active,
    TypedRouterState state,
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
        child: _gated(
          active,
          state,
          Builder(
            builder: (context) => tabs.node.builder(context, state, shell),
          ),
        ),
      ),
      'tabs',
    );
  }

  /// [frame] of [level], giving back to what is inside while it handles back.
  Widget _gated(ShellLevel level, TypedRouterState state, Widget frame) =>
      LevelPopGate(
        inside: LevelInside(level, state, _currentNavigators),
        child: frame,
      );
}
