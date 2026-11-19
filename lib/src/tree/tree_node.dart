import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:typed_navigator/src/page/page_factory.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/split/split_presentation.dart';
import 'package:typed_navigator/src/split/split_view.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/tabs/stateful_shell.dart';
import 'package:typed_navigator/src/tree/navigator_slot.dart';
import 'package:typed_navigator/src/tree/no_parent_route.dart';

part 'branch_node.dart';
part 'parented_route_node.dart';
part 'route_node.dart';
part 'shell_node.dart';
part 'split_node.dart';
part 'stateful_shell_node.dart';

// TreeNode is sealed, so its variants live in this library. The functions a
// node holds are only called from the node's own methods, where the route
// type is known: read through a wider type they would fail Dart's covariance
// check at runtime.

/// A node of the route tree, declared top-down.
///
/// [P] is the type of the route directly above the node. A node that needs
/// nothing from above is a `TreeNode<NoParentRoute>`; a node that builds its
/// parent route ([RouteNode.withParent]) is a `TreeNode<ThatParentRoute>`, so
/// the compiler only lets it sit under that parent.
sealed class TreeNode<P> {
  const TreeNode();
}
