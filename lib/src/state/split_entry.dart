part of 'shell_level.dart';

/// One instance of a split on the stack.
///
/// While the split shows a stack, [navigatorKey] holds it. While it shows
/// columns, [columnsNavigatorKey] holds the page with the row of columns
/// and the cover pages above it, and every column has a navigator of its
/// own ([columnKeyOf]) that moves with its route along the row.
final class SplitEntry extends ShellLevel implements ColumnOwner {
  /// Creates a new instance of [node].
  SplitEntry(this.node);

  /// The node this instance shows.
  final SplitNode<Object?> node;

  /// The key of the navigator holding the row of columns and the covers.
  final GlobalKey<NavigatorState> columnsNavigatorKey =
      GlobalKey<NavigatorState>();

  /// Keys the frame the split's builder makes, so it keeps its state when
  /// the split switches between a stack and columns.
  final GlobalKey frameKey = GlobalKey();

  final Expando<GlobalKey<NavigatorState>> _columnKeys = Expando();

  /// The key of the column navigator of [owner]. The same owner has the
  /// same key.
  GlobalKey<NavigatorState> columnKeyOf(ColumnOwner owner) =>
      _columnKeys[owner] ??= GlobalKey<NavigatorState>();

  /// What owns the column [entry], which stands in this split, is in: the
  /// entry itself, or the level nested right inside this split.
  ColumnOwner columnOwnerOf(NavigationEntry entry) {
    final depth = entry.levels.indexOf(this);
    return depth + 1 < entry.levels.length
        ? entry.levels[depth + 1].columnOwner
        : entry;
  }

  @override
  ColumnOwner get columnOwner => this;

  @override
  GlobalKey get pageContentKey => frameKey;

  @override
  List<GlobalKey<NavigatorState>> get ownNavigatorKeys => [
    navigatorKey,
    columnsNavigatorKey,
  ];

  @override
  bool isInstanceOf(Nesting nesting) =>
      nesting is SplitNesting && identical(nesting.node, node);

  @override
  ShellLevel? takenOverFor(Nesting nesting) =>
      isInstanceOf(nesting) ? this : null;

  /// The stack's navigator, the columns' navigator, and the column [top]
  /// is in; the ones not mounted are skipped.
  @override
  List<GlobalKey<NavigatorState>> navigatorKeysToward(NavigationEntry top) => [
    navigatorKey,
    columnsNavigatorKey,
    columnKeyOf(columnOwnerOf(top)),
  ];

  @override
  String toString() => 'SplitEntry(${identityHashCode(this)})';
}
