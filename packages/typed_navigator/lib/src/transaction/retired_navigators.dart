import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/src/transaction/entry_lifecycle.dart';

/// Closes what is left in the navigator of a level (a shell instance, a branch
/// of tabs) that leaves the state.
///
/// Flutter disposes a nested navigator with its routes, and a pageless
/// route in it (`showDialog(useRootNavigator: false)`,
/// `Navigator.of(context).push`) never completes its `Future`. While the
/// navigator is still mounted, this pops every route above its first one,
/// deepest navigator first, so those routes complete with `null`. Pages it
/// pops are already gone from the state; the router ignores them.
class RetiredNavigators implements EntryLifecycle {
  /// Creates the lifecycle.
  const RetiredNavigators();

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
      level.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  /// Nothing: the router is gone, and its navigators go with the widget
  /// tree.
  @override
  void stackDisposed(List<NavigationEntry> entries) {}
}
