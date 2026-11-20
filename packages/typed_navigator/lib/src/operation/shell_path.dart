import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/shell_level.dart';
import 'package:typed_navigator/src/tree/nesting.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';

/// Decides which levels (shell instances, branches of tabs) a new entry stands
/// in.
///
/// The rule: reuse as many existing navigators as possible. A route joins
/// the levels of the entry right below it; for `go` it may instead take
/// over the levels of an entry it replaces: the same shell instance, and
/// for tabs the same instance in the route's branch (a branch switch).
/// Whichever reuses more levels wins; every level past them is new.
final class ShellPath {
  /// Creates the path finder for routes of [_tree].
  ShellPath(this._tree);

  final RouteTree _tree;

  /// The levels for [route] right above an entry inside [below], or taking
  /// over one of [replaceable] (the levels of the entries the navigation
  /// replaces). Throws [ArgumentError] when [route]'s type has no node.
  List<ShellLevel> levelsFor(
    TypedRoute<Object?> route, {
    required List<ShellLevel> below,
    Iterable<List<ShellLevel>> replaceable = const [],
  }) {
    final nestings = _tree.nestingsOf(route);
    var reused = _joined(nestings, below);
    for (final levels in replaceable) {
      final takenOver = _takenOver(nestings, levels);
      if (takenOver.length > reused.length) reused = takenOver;
    }
    return [
      ...reused,
      for (final nesting in nestings.skip(reused.length)) _new(nesting),
    ];
  }

  /// The levels of [levels] that are instances of [nestings], from the
  /// outer one, until the first that is not.
  List<ShellLevel> _joined(List<Nesting> nestings, List<ShellLevel> levels) =>
      levels.take(_joinedDepth(nestings, levels)).toList();

  int _joinedDepth(List<Nesting> nestings, List<ShellLevel> levels) {
    var depth = 0;
    while (depth < nestings.length &&
        depth < levels.length &&
        levels[depth].isInstanceOf(nestings[depth])) {
      depth++;
    }
    return depth;
  }

  /// As [_joined], and where [levels] hold another branch of the same tabs
  /// instance, that instance's branch of the route; nothing deeper, since
  /// the rest of the other branch is not the route's.
  List<ShellLevel> _takenOver(List<Nesting> nestings, List<ShellLevel> levels) {
    final reused = _joined(nestings, levels);
    final depth = reused.length;
    if (depth < nestings.length && depth < levels.length) {
      if (levels[depth].takenOverFor(nestings[depth]) case final other?) {
        reused.add(other);
      }
    }
    return reused;
  }

  ShellLevel _new(Nesting nesting) => switch (nesting) {
    ShellNesting(:final node) => ShellEntry(node),
    BranchNesting(:final node, :final branch) => TabsEntry(node).branch(branch),
  };
}
