import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/state/column_owner.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';

/// The pageless routes in a split's navigators: those over the visible columns
/// left of the top entry's go first on back, and a change of projection closes
/// those in the split's own navigators first. A route lies over a page while
/// that page is not current in its navigator.
///
/// Reads routes: call its methods outside a build.
final class PagelessColumns {
  /// Creates the lookup.
  const PagelessColumns();

  /// The navigators holding a pageless route over a visible column of
  /// [split] in [state] left of the top entry's, the rightmost first: over
  /// the column's top page (inside a shell or tabs too), or over its page.
  List<NavigatorState> rightmostFirst(
    SplitEntry split,
    NavigationState state,
  ) {
    final columns = _columnsIn(split, state);
    if (columns.isEmpty) return const [];
    final topOwner = split.columnOwnerOf(state.entries.last);
    return [
      for (final MapEntry(key: owner, value: top)
          in columns.entries.toList().reversed)
        if (owner != topOwner && _isVisible(split, owner))
          ?_holderOver(top.screenKey) ?? _holderOver(owner.pageContentKey),
    ];
  }

  /// Whether one of [split]'s own navigators holds a pageless route the
  /// next change of projection would lose: over the stack's top page, over
  /// a column, over the top cover, or over the row.
  bool isAnyOpen(SplitEntry split, NavigationState state) {
    final owners = _columnsIn(split, state).keys.toList();
    if (owners.isEmpty) return false;
    if (split.navigatorKey.currentState != null) {
      return _isCovered(owners.last.pageContentKey);
    }
    final columnsNavigator = split.columnsNavigatorKey.currentState;
    final covers = [
      for (final owner in owners)
        if (_navigatorOf(owner.pageContentKey) == columnsNavigator) owner,
    ];
    return owners.any(
          (owner) =>
              !covers.contains(owner) && _isCovered(owner.pageContentKey),
        ) ||
        _isCovered((covers.lastOrNull ?? split).pageContentKey);
  }

  /// Closes the pageless routes of [split]'s own navigators in [state];
  /// their pushes complete with `null`.
  void closeAll(SplitEntry split, NavigationState state) {
    final keys = [
      split.navigatorKey,
      split.columnsNavigatorKey,
      for (final owner in _columnsIn(split, state).keys)
        split.columnKeyOf(owner),
    ];
    for (final key in keys) {
      key.currentState?.popUntil((route) => route.settings is Page<Object?>);
    }
  }

  /// The column owners of [split]'s entries on the active path, bottom to
  /// top, each with the top entry of its column; none for a split in a
  /// branch not on screen.
  Map<ColumnOwner, NavigationEntry> _columnsIn(
    SplitEntry split,
    NavigationState state,
  ) => {
    for (final entry in state.entries)
      if (entry.isIn(split)) split.columnOwnerOf(entry): entry,
  };

  /// Whether [owner]'s column is on screen: not kept offstage by a window
  /// shift, not under a cover.
  bool _isVisible(SplitEntry split, ColumnOwner owner) =>
      switch (split.columnKeyOf(owner).currentContext) {
        final column? => TickerMode.valuesOf(column).enabled,
        null => false,
      };

  /// The navigator holding a route over the page keyed [key], or `null`.
  NavigatorState? _holderOver(GlobalKey key) =>
      _isCovered(key) ? _navigatorOf(key) : null;

  bool _isCovered(GlobalKey key) => switch (key.currentContext) {
    final content? => ModalRoute.isCurrentOf(content) == false,
    null => false,
  };

  NavigatorState? _navigatorOf(GlobalKey key) => switch (key.currentContext) {
    final content? => Navigator.maybeOf(content),
    null => null,
  };
}
