import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/tree/tree_node.dart';

/// One instance of a shell on the stack: its node and the key of its navigator.
///
/// Compared by identity, like a page: the same instance keeps its
/// navigator and the state of its frame; a new instance of the same node is
/// another navigator. Entries of routes hold the instances around them
/// (`NavigationEntry.shells`); a shell no entry holds does not exist.
///
/// Internal: not exported.
final class ShellEntry {
  /// Creates a new instance of [node].
  ShellEntry(this.node);

  /// The node this instance shows.
  final ShellNode<Object?> node;

  /// The key of this instance's navigator.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  String toString() => 'ShellEntry(${identityHashCode(this)})';
}
