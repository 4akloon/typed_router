import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/split/column_closing.dart';

/// What back from a page does when its navigator in a split must keep the back
/// gesture away from it: the page holds a local history entry that implies an
/// app bar's back button, and popping that entry does the variant's work.
sealed class ColumnBack {
  const ColumnBack();

  /// Whether a page whose route is [route] holds the entry.
  bool holdsEntryOn(ModalRoute<Object?> route);

  /// The entry of the page whose route is [route] was popped.
  void popped(ModalRoute<Object?> route);
}

/// A page in a column left of the deepest: back closes the column and the
/// columns to its right, asking the pages to its right first.
final class ClosesColumn extends ColumnBack {
  /// Creates the closing through [_closing].
  const ClosesColumn(this._closing);

  final ColumnClosing _closing;

  @override
  bool holdsEntryOn(ModalRoute<Object?> route) => true;

  @override
  void popped(ModalRoute<Object?> route) => _closing.tryClose(
    // Navigator tells a route it popped only when the route itself leaves,
    // not its local history; the page's PopScope must hear it.
    beforeClosing: () => route.onPopInvokedWithResult(true, null),
  );
}

/// A page whose navigator must not take the gesture (inside a level in a
/// middle column, or the deepest column while a pageless route lies in a
/// column to its left): back removes the page, as `Navigator.pop` would.
final class RemovesPage extends ColumnBack {
  /// Creates the removal through [_remove], the navigator's
  /// `onDidRemovePage`.
  const RemovesPage(this._remove);

  final void Function(Page<Object?> page) _remove;

  /// The first page of a navigator has nothing below it to go back to.
  @override
  bool holdsEntryOn(ModalRoute<Object?> route) => !route.isFirst;

  /// The navigator tells the page's `PopScope` when it removes the page.
  @override
  void popped(ModalRoute<Object?> route) {
    if (route.settings case final Page<Object?> page) _remove(page);
  }
}
