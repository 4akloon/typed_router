import 'package:typed_navigator/src/operation/entry_chain.dart';
import 'package:typed_navigator/src/operation/go_plan.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';

/// The active path after switching or resetting a branch of a tabs instance, as
/// go_router's `goBranch`: the entries below the tabs, then the branch's stack.
/// What was above the tabs goes.
class BranchSwitch {
  /// Creates the switch over routes of [_tree], making entries with
  /// [_entryChain] and resetting with [_goPlan].
  BranchSwitch(this._tree, this._entryChain, this._goPlan);

  final RouteTree _tree;
  final EntryChain _entryChain;
  final GoPlan _goPlan;

  /// The path showing [branchType] of [tabs]: the active branch as it is,
  /// another branch's kept stack, or its initial chain on the first visit.
  /// `null` when [tabs] is not on the active path.
  List<NavigationEntry>? shown(
    NavigationState current,
    TabsEntry tabs,
    Type branchType,
  ) {
    final inTabs = _entriesIn(current, tabs);
    if (inTabs.isEmpty) return null;
    final below = _below(current, inTabs.first);
    if (inTabs.first.branchOf(tabs)?.branchType == branchType) {
      return [...below, ...inTabs];
    }
    return switch (current.inactiveBranches.stackOf(tabs, branchType)) {
      final kept? => [...below, ...kept],
      null => _initial(below, inTabs.first, tabs, branchType),
    };
  }

  /// The path showing [branchType] of [tabs] from its initial chain: `go`
  /// to the initial route from the branch's stack (go_router's
  /// `initialLocation: true`), so the entries the chain shares with that
  /// stack stay, with their screens. `null` when [tabs] is not on the
  /// active path.
  List<NavigationEntry>? reset(
    NavigationState current,
    TabsEntry tabs,
    Type branchType,
  ) {
    final inTabs = _entriesIn(current, tabs);
    if (inTabs.isEmpty) return null;
    final below = _below(current, inTabs.first);
    final stack = inTabs.first.branchOf(tabs)?.branchType == branchType
        ? inTabs
        : current.inactiveBranches.stackOf(tabs, branchType) ?? const [];
    return _goPlan.entriesFrom(
      current,
      [...below, ...stack],
      [
        for (final entry in below) entry.route,
        ..._tree.chainTo(tabs.node.branchOf(branchType).initial),
      ],
    );
  }

  /// The initial chain of [branchType], standing where [firstInTabs] stands
  /// but in that branch.
  List<NavigationEntry> _initial(
    List<NavigationEntry> below,
    NavigationEntry firstInTabs,
    TabsEntry tabs,
    Type branchType,
  ) => _entryChain.chained(
    below,
    _tree.chainTo(tabs.node.branchOf(branchType).initial),
    replaceable: [firstInTabs.levelsIn(tabs, branchType)],
  );

  List<NavigationEntry> _entriesIn(NavigationState current, TabsEntry tabs) => [
    for (final entry in current.entries)
      if (entry.standsIn(tabs)) entry,
  ];

  List<NavigationEntry> _below(
    NavigationState current,
    NavigationEntry firstInTabs,
  ) => current.entries.take(current.entries.indexOf(firstInTabs)).toList();
}
