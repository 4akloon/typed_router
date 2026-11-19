import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/state/column_owner.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/src/transaction/entry_lifecycle.dart';

/// Closes what is left in the navigator of a level (a shell or split instance,
/// a branch of tabs) or of a split's column that leaves the state.
///
/// Flutter disposes a nested navigator with its routes, and a pageless
/// route in it (`showDialog(useRootNavigator: false)`,
/// `Navigator.of(context).push`) never completes its `Future`. While the
/// navigator is still mounted, this pops every route above its first one,
/// deepest navigator first, so those routes complete with `null`. Pages it
/// pops are already gone from the state; the router ignores them.
final class RetiredNavigators implements EntryLifecycle {
  /// Creates the lifecycle.
  const RetiredNavigators();

  @override
  void entriesLeft(List<NavigationEntry> left, NavigationState remains) {
    final levelsInUse = {
      for (final entry in remains.allEntries) ...entry.levels,
    };
    final columnsInUse = {
      for (final entry in remains.allEntries) ..._columnsOf(entry),
    };
    final retired = <(num, GlobalKey<NavigatorState>)>{
      for (final entry in left) ...[
        for (final (depth, level) in entry.levels.indexed)
          if (!levelsInUse.contains(level))
            for (final key in level.ownNavigatorKeys) (depth, key),
        // A split's column sits between the split and the levels in it.
        for (final (split, owner) in _columnsOf(entry))
          if (!columnsInUse.contains((split, owner)))
            (entry.levels.indexOf(split) + 0.5, split.columnKeyOf(owner)),
      ],
    }.toList()..sort((first, second) => second.$1.compareTo(first.$1));
    for (final (_, key) in retired) {
      key.currentState?.popUntil((route) => route.isFirst);
    }
  }

  /// The split columns [entry] stands in: each split with the owner of
  /// [entry]'s column in it.
  List<(SplitEntry, ColumnOwner)> _columnsOf(NavigationEntry entry) => [
    for (final level in entry.levels)
      if (level case final SplitEntry split)
        (split, split.columnOwnerOf(entry)),
  ];

  /// Nothing: the router is gone, and its navigators go with the widget
  /// tree.
  @override
  void stackDisposed(List<NavigationEntry> entries) {}
}
