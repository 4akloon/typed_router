import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/split/column_closing.dart';

/// Tells the pages of one navigator whether back from them closes their split
/// column: [closing] for a column on screen that is neither the deepest nor the
/// split's first, else `null`.
///
/// Every nested navigator puts one above its pages, so the pages of a
/// navigator inside a column (a shell's) do not see the column's.
final class ColumnBackScope extends InheritedWidget {
  /// Creates the scope of the navigator in [child].
  const ColumnBackScope({
    required this.closing,
    required super.child,
    super.key,
  });

  /// Closes the column and the columns to its right, asking the pages to
  /// its right first; `null` when back does not close the column this way.
  final ColumnClosing? closing;

  /// The projection makes a new closing on every build: the pages hear of
  /// each, so they always close the column with the latest one.
  @override
  bool updateShouldNotify(ColumnBackScope oldWidget) =>
      oldWidget.closing != closing;
}
