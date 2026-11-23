import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/router/navigator_top.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/src/transaction/entry_lifecycle.dart';

/// Closes what is left in the navigator of a level (a shell instance, a branch
/// of tabs) that leaves the state.
///
/// Flutter disposes a nested navigator with its routes, and a pageless route in
/// it (`showDialog(useRootNavigator: false)`, `Navigator.of(context).push`)
/// never completes its `Future`. While the navigator is still mounted, this
/// removes every route above its first one, from the top, deepest navigator
/// first: those routes complete with `null`, and observers hear `didRemove`, as
/// for the pages `go` removes from the root navigator; nobody popped them.
/// Pages it removes are already gone from the state; the router ignores them.
class RetiredNavigators implements EntryLifecycle {
  /// Creates the lifecycle.
  const RetiredNavigators();

  final NavigatorTop _top = const NavigatorTop();

  @override
  void entriesLeft(List<NavigationEntry> left, NavigationState remains) {
    final inUse = {
      for (final entry in remains.allEntries) ...entry.levels,
    };
    final retired = <(int, ShellLevel)>{
      for (final entry in left)
        for (final (depth, level) in entry.levels.indexed)
          if (!inUse.contains(level)) (depth, level),
    }.toList()..sort((first, second) => second.$1.compareTo(first.$1));
    for (final (_, level) in retired) {
      if (level.navigatorKey.currentState case final navigator?) {
        _removeAboveFirst(navigator);
      }
    }
  }

  void _removeAboveFirst(NavigatorState navigator) {
    for (var top = _top.of(navigator); top != null && !top.isFirst;) {
      navigator.removeRoute(top);
      top = _top.of(navigator);
    }
  }

  /// Nothing: the router is gone, and its navigators go with the widget
  /// tree.
  @override
  void stackDisposed(List<NavigationEntry> entries) {}
}
