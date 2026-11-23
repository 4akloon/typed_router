import 'package:flutter/foundation.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/shell_level.dart';

/// The kept stacks of the branches not on screen, per tabs instance. An
/// immutable value that keeps its own invariants: a kept stack belongs to a
/// branch that is not active, of tabs that can still be reached from the active
/// path, directly or through other kept stacks (nested tabs).
///
/// Its entries are still on the stack: their pushes wait.
class InactiveBranches {
  /// No kept stacks.
  const InactiveBranches.none() : _stacks = const {};

  const InactiveBranches._(this._stacks);

  final Map<TabsEntry, Map<Type, List<NavigationEntry>>> _stacks;

  /// The kept stack of [branch] in [tabs], or `null` when the branch has
  /// none (not visited, or active).
  List<NavigationEntry>? stackOf(TabsEntry tabs, Type branch) =>
      _stacks[tabs]?[branch];

  /// The kept stacks of [tabs], one per branch not on screen.
  Iterable<List<NavigationEntry>> stacksOf(TabsEntry tabs) =>
      _stacks[tabs]?.values ?? const [];

  /// Every entry of every kept stack.
  Iterable<NavigationEntry> get entries => [
    for (final branches in _stacks.values)
      for (final stack in branches.values) ...stack,
  ];

  /// The kept stacks once the active path changes from [previous] to
  /// [next]: a tabs instance that shows another branch keeps the stack of
  /// the one it left; the branch it shows has no kept stack (its entries
  /// are on the path now, or leave); stacks of tabs that can no longer be
  /// reached are dropped.
  InactiveBranches afterShowing(
    List<NavigationEntry> previous,
    List<NavigationEntry> next,
  ) {
    final stacks = {
      for (final MapEntry(key: tabs, value: branches) in _stacks.entries)
        tabs: {...branches},
    };
    final left = _activeBranches(previous);
    for (final shown in _activeBranches(next).values) {
      final branches = stacks.putIfAbsent(shown.tabs, () => {});
      if (left[shown.tabs] case final before?
          when before.branchType != shown.branchType) {
        branches[before.branchType] = List.unmodifiable([
          for (final entry in previous)
            if (entry.isIn(before)) entry,
        ]);
      }
      branches.remove(shown.branchType);
    }
    return InactiveBranches._(_reachable(stacks, next));
  }

  /// The kept stacks without [removed]: pages a navigator popped by itself
  /// in a branch not on screen.
  InactiveBranches without(Set<NavigationEntry> removed) => InactiveBranches._(
    Map.unmodifiable({
      for (final MapEntry(key: tabs, value: branches) in _stacks.entries)
        tabs: Map<Type, List<NavigationEntry>>.unmodifiable({
          for (final MapEntry(key: branch, value: stack) in branches.entries)
            if (stack.where((entry) => !removed.contains(entry)).toList()
                case final kept when kept.isNotEmpty)
              branch: List<NavigationEntry>.unmodifiable(kept),
        }),
    }),
  );

  Map<TabsEntry, BranchEntry> _activeBranches(List<NavigationEntry> path) => {
    for (final entry in path)
      for (final branch in entry.branches) branch.tabs: branch,
  };

  /// [stacks] of the tabs reachable from [path], directly or through the
  /// kept stacks of reachable tabs.
  Map<TabsEntry, Map<Type, List<NavigationEntry>>> _reachable(
    Map<TabsEntry, Map<Type, List<NavigationEntry>>> stacks,
    List<NavigationEntry> path,
  ) {
    final reachable = {..._activeBranches(path).keys};
    var pending = [...reachable];
    while (pending.isNotEmpty) {
      pending = [
        for (final tabs in pending)
          for (final stack
              in stacks[tabs]?.values ?? const <List<NavigationEntry>>[])
            for (final entry in stack)
              for (final branch in entry.branches)
                if (reachable.add(branch.tabs)) branch.tabs,
      ];
    }
    return Map.unmodifiable({
      for (final tabs in reachable)
        if (stacks[tabs] case final branches? when branches.isNotEmpty)
          tabs: Map<Type, List<NavigationEntry>>.unmodifiable(branches),
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InactiveBranches && _holdsSameStacksAs(other);

  @override
  int get hashCode => Object.hashAllUnordered([
    for (final MapEntry(key: tabs, value: branches) in _stacks.entries)
      Object.hash(
        tabs,
        Object.hashAllUnordered([
          for (final MapEntry(key: branch, value: stack) in branches.entries)
            Object.hash(branch, Object.hashAll(stack)),
        ]),
      ),
  ]);

  @override
  String toString() => 'InactiveBranches($_stacks)';

  bool _holdsSameStacksAs(InactiveBranches other) {
    if (other._stacks.length != _stacks.length) return false;
    for (final MapEntry(key: tabs, value: branches) in _stacks.entries) {
      final otherBranches = other._stacks[tabs];
      if (otherBranches == null || otherBranches.length != branches.length) {
        return false;
      }
      for (final MapEntry(key: branch, value: stack) in branches.entries) {
        if (!listEquals(otherBranches[branch], stack)) return false;
      }
    }
    return true;
  }
}
