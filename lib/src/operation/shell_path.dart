import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/shell_entry.dart';
import 'package:typed_navigator/src/tree/route_tree.dart';

/// Decides which shell instances a new entry stands in.
///
/// A route goes right above an entry: it joins that entry's shell
/// instances while their nodes match its own shells from the outside in, so
/// a navigation that stays in a shell keeps its navigator. From the first
/// shell that differs, every instance is new.
final class ShellPath {
  /// Creates the path finder for routes of [_tree].
  ShellPath(this._tree);

  final RouteTree _tree;

  /// The shell instances for [route] placed right above an entry inside
  /// [below] (outer first; empty above a root entry or at the bottom).
  /// Throws [ArgumentError] when [route]'s type has no node.
  List<ShellEntry> instancesFor(
    TypedRoute<Object?> route, {
    required List<ShellEntry> below,
  }) {
    final instances = <ShellEntry>[];
    var isJoining = true;
    for (final (level, node) in _tree.shellNodesOf(route).indexed) {
      isJoining =
          isJoining &&
          level < below.length &&
          identical(below[level].node, node);
      instances.add(isJoining ? below[level] : ShellEntry(node));
    }
    return instances;
  }
}
