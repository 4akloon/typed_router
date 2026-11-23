import 'package:typed_router/src/state/inactive_branches.dart';
import 'package:typed_router/src/state/navigation_entry.dart';
import 'package:typed_router/src/state/shell_level.dart';
import 'package:typed_router/src/state/stack_parts.dart';

// The description names branch types, for logs and test failures in debug
// builds.
// ignore_for_file: avoid_type_to_string

/// The text of a stack for logs and test failures: routes joined with
/// ` > `, a shell's navigator in brackets, tabs in braces with every
/// visited branch and the active one starred:
/// `{*RoomsBranch: [RoomsRoute() > RoomRoute(7)] | HomeBranch: [HomeRoute()]}`.
class StackDescription {
  /// Creates the description of [_entries] with the kept stacks of
  /// [_inactive].
  const StackDescription(this._entries, this._inactive);

  final List<NavigationEntry> _entries;
  final InactiveBranches _inactive;
  final StackParts _parts = const StackParts();

  @override
  String toString() => _describe(_entries, 0);

  String _describe(List<NavigationEntry> entries, int depth) => _parts
      .of(entries, depth)
      .map(
        (part) => switch (part) {
          RoutePart(:final entry) => '${entry.route}',
          LevelPart(:final level, :final entries) => _describeLevel(
            level,
            entries,
            depth + 1,
          ),
        },
      )
      .join(' > ');

  String _describeLevel(
    ShellLevel level,
    List<NavigationEntry> entries,
    int depth,
  ) => switch (level) {
    BranchEntry(:final tabs, :final branchType) =>
      '{${_describeBranches(tabs, branchType, entries, depth)}}',
    ShellEntry() => '[${_describe(entries, depth)}]',
  };

  String _describeBranches(
    TabsEntry tabs,
    Type activeBranch,
    List<NavigationEntry> activeEntries,
    int depth,
  ) => [
    for (final branch in tabs.branchTypes)
      if (branch == activeBranch)
        '*$branch: [${_describe(activeEntries, depth)}]'
      else if (_inactive.stackOf(tabs, branch) case final stack?)
        '$branch: [${_describe(stack, depth)}]',
  ].join(' | ');
}
