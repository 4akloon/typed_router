import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/split/column_back.dart';

/// Tells the pages of one navigator what back from them does when their
/// navigator in a split keeps the back gesture away: [back], or `null` for an
/// ordinary navigator.
///
/// Every nested navigator puts one above its pages, so the pages of a
/// navigator inside a column (a shell's) do not see the column's.
final class ColumnBackScope extends InheritedWidget {
  /// Creates the scope of the navigator in [child].
  const ColumnBackScope({required this.back, required super.child, super.key});

  /// What back from the pages does; `null` for an ordinary navigator.
  final ColumnBack? back;

  /// The projection makes a new value on every build: the pages hear of
  /// each, so they always act with the latest one.
  @override
  bool updateShouldNotify(ColumnBackScope oldWidget) => oldWidget.back != back;
}
