import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/level_inside.dart';
import 'package:typed_navigator/src/page/level_pop_gate.dart';
import 'package:typed_navigator/src/page/page_factory.dart';
import 'package:typed_navigator/src/page/page_request.dart';
import 'package:typed_navigator/src/page/route_pages.dart';
import 'package:typed_navigator/src/router/current_navigators.dart';
import 'package:typed_navigator/src/split/blank_page_key.dart';
import 'package:typed_navigator/src/split/column_back_entry.dart';
import 'package:typed_navigator/src/split/split_part.dart';
import 'package:typed_navigator/src/split/split_projection.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/src/tabs/branch_switching.dart';
import 'package:typed_navigator/src/tabs/stateful_shell.dart';

/// Makes the page that holds a nested navigator: a shell's, a tabs instance's
/// with its branch navigators, or a split's with its projection. The page comes
/// from the node's factory or the router's and is keyed by the instance.
final class LevelPages {
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
    NavigationState state,
    Widget navigator,
  ) => _routePages.created(
    shell.node.pageFactoryOr(_pageFactory),
    PageRequest(
      key: ObjectKey(shell),
      // Keyed, so the frame keeps its state when a split moves the page to
      // another navigator.
      child: _gated(
        shell,
        state,
        KeyedSubtree(
          key: shell.frameKey,
          child: Builder(
            builder: (context) => shell.node.builder(context, state, navigator),
          ),
        ),
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
        child: _gated(
          active,
          state,
          KeyedSubtree(
            key: tabs.frameKey,
            child: Builder(
              builder: (context) => tabs.node.builder(context, state, shell),
            ),
          ),
        ),
      ),
      'tabs',
    );
  }

  /// The page of [split], showing [parts] as a stack or as columns; the
  /// navigators report the pages they remove to [onDidRemovePage], the
  /// column navigators to [onDidRemoveColumn].
  Page<Object?> splitPage(
    SplitEntry split,
    NavigationState state,
    List<SplitPart> parts, {
    required void Function(Page<Object?> page) onDidRemovePage,
    required void Function(Page<Object?> page, SplitEntry split)
    onDidRemoveColumn,
  }) => _routePages.created(
    split.node.pageFactoryOr(_pageFactory),
    PageRequest(
      key: ObjectKey(split),
      child: _gated(
        split,
        state,
        SplitProjection(
          split: split,
          state: state,
          parts: parts,
          blankPage: (child) => _internalPage(const BlankPageKey(), child),
          rowPage: (row) =>
              _internalPage(ObjectKey(split.columnsNavigatorKey), row),
          onDidRemovePage: onDidRemovePage,
          onDidRemoveColumn: onDidRemoveColumn,
        ),
      ),
    ),
    'a split',
  );

  /// [frame] of [level], giving back to what is inside while it handles back.
  Widget _gated(ShellLevel level, NavigationState state, Widget frame) =>
      LevelPopGate(
        inside: LevelInside(level, state, _currentNavigators),
        child: ColumnBackEntry(child: frame),
      );

  /// A page of the router's own: the row of a split's columns, the empty
  /// page under a column.
  Page<Object?> _internalPage(LocalKey key, Widget child) => _routePages
      .created(_pageFactory, PageRequest(key: key, child: child), 'a split');
}
