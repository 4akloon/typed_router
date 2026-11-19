import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/tree/navigator_slot.dart';
import 'package:typed_navigator/src/tree/nesting_path.dart';
import 'package:typed_navigator/src/tree/tree_node.dart';

// Messages name route types; type names are readable in debug builds, where
// these errors are met.
// ignore_for_file: avoid_type_to_string

/// The navigator slots of one tree: each slot names one shell, split or branch,
/// and a route with a `parentNavigatorSlot` shows in that slot's navigator.
final class SlotPlacement {
  /// Creates the placement with only the root slot taken.
  SlotPlacement();

  final Set<NavigatorSlot> _used = {NavigatorSlot.root};

  /// [slot], once: a slot names one shell or branch.
  NavigatorSlot? claimed(NavigatorSlot? slot) {
    if (slot != null && !_used.add(slot)) {
      throw ArgumentError(
        'A NavigatorSlot is given to two shells, splits or branches. Give '
        'each its own slot.',
      );
    }
    return slot;
  }

  /// [path] shown where [node]'s `parentNavigatorSlot` says.
  NestingPath placed(RouteNode<TypedRoute<Object?>> node, NestingPath path) {
    final slot = node.parentNavigatorSlot;
    if (slot == null) return path;
    if (path.placedIn(slot) case final placed?) return placed;
    if (path.isBelowShown(slot)) {
      throw ArgumentError(
        "${node.routeType}'s parentNavigatorSlot names a navigator deeper "
        'than the one its parent route is shown in. A route shows in its '
        "parent's navigator or further out: use that navigator's slot or an "
        'outer one.',
      );
    }
    throw ArgumentError(
      "${node.routeType}'s parentNavigatorSlot is neither the root nor the "
      'slot of a shell, split or branch above it. Use NavigatorSlot.root or '
      'the slot of an enclosing ShellNode, SplitNode or BranchNode.',
    );
  }
}
