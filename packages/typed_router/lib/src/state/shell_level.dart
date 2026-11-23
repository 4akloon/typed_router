import 'package:flutter/widgets.dart';
import 'package:typed_router/src/tree/navigator_slot.dart';
import 'package:typed_router/src/tree/nesting.dart';
import 'package:typed_router/src/tree/tree_node.dart';

part 'branch_entry.dart';
part 'shell_entry.dart';
part 'tabs_entry.dart';

/// One level of navigators a stack entry stands in: an instance of a shell
/// ([ShellEntry]) or one branch of an instance of tabs ([BranchEntry]). Every
/// level has a navigator of its own.
///
/// Compared by identity: the same level object is the same navigator.
/// Internal: not exported.
sealed class ShellLevel {
  ShellLevel();

  /// The key of this level's navigator.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// The slot the tree gives this level's navigator, or `null`.
  NavigatorSlot? get slot;

  /// Whether this level is an instance of [nesting] from the tree.
  bool isInstanceOf(Nesting nesting);

  /// The same level of [nesting] where this one can stand for it: this
  /// level itself when it is an instance of [nesting], the branch of
  /// [nesting] in this level's tabs when it is another branch of the same
  /// tabs; `null` otherwise.
  ShellLevel? takenOverFor(Nesting nesting);
}
