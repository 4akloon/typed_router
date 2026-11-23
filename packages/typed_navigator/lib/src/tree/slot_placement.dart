import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/tree/nesting_path.dart';
import 'package:typed_navigator/src/tree/tree_node.dart';

// A node without a name is named by its route type in these messages; type
// names are readable in debug builds, where these errors are met.
// ignore_for_file: avoid_type_to_string

/// Where a route node's `parentNavigatorSlot` shows its routes: the navigator
/// of that slot, which must be the root or one around the node.
class SlotPlacement {
  /// Creates the placement.
  const SlotPlacement();

  /// [path] shown where [node]'s `parentNavigatorSlot` says.
  NestingPath placed(RouteNode<TypedRoute<Object?>> node, NestingPath path) {
    final slot = node.parentNavigatorSlot;
    if (slot == null) return path;
    if (path.placedIn(slot) case final placed?) return placed;
    // Named by its name when it has one.
    final label = node.name ?? '${node.routeType}';
    if (path.isBelowShown(slot)) {
      throw ArgumentError(
        "$label's parentNavigatorSlot names a navigator deeper "
        'than the one its parent route is shown in. A route shows in its '
        "parent's navigator or further out: use that navigator's slot or an "
        'outer one.',
      );
    }
    throw ArgumentError(
      "$label's parentNavigatorSlot is neither the root nor the "
      'slot of a shell or branch above it. Use NavigatorSlot.root or the '
      'slot of an enclosing ShellNode or BranchNode.',
    );
  }
}
