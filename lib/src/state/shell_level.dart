import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/state/column_owner.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/tree/nesting.dart';
import 'package:typed_navigator/src/tree/tree_node.dart';

part 'branch_entry.dart';
part 'shell_entry.dart';
part 'split_entry.dart';
part 'tabs_entry.dart';

/// One level of navigators a stack entry stands in: an instance of a shell
/// ([ShellEntry]) or a split ([SplitEntry]), or one branch of an instance of
/// tabs ([BranchEntry]). Every level has a navigator of its own.
///
/// Compared by identity: the same level object is the same navigator.
/// Internal: not exported.
sealed class ShellLevel {
  ShellLevel();

  /// The key of this level's navigator.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// The keys of this level's navigators toward [top], an entry standing in it,
  /// outer first: where the back button looks.
  List<GlobalKey<NavigatorState>> navigatorKeysToward(NavigationEntry top) => [
    navigatorKey,
  ];

  /// The keys of the navigators this level owns, to close what is left in them
  /// when it leaves the state.
  List<GlobalKey<NavigatorState>> get ownNavigatorKeys => [navigatorKey];

  /// What owns this level's column when it is nested right inside a split: the
  /// level itself, or, for a branch, its tabs instance.
  ColumnOwner get columnOwner;

  /// Whether this level is an instance of [nesting] from the tree.
  bool isInstanceOf(Nesting nesting);

  /// The same level of [nesting] where this one can stand for it: this
  /// level itself when it is an instance of [nesting], the branch of
  /// [nesting] in this level's tabs when it is another branch of the same
  /// tabs; `null` otherwise.
  ShellLevel? takenOverFor(Nesting nesting);
}
