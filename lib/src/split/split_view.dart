import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:typed_navigator/src/split/split_column.dart';

/// The columns of a `SplitNode` on screen, laid out in a row; what the split's
/// builder frames.
///
/// Every column but the last is one [maximumColumns]-th of the width; the
/// last takes the rest. To lay them out yourself (dividers, your own
/// widths, an animated shift), build from [columns] instead of showing this
/// widget:
///
/// ```dart
/// builder: (context, state, split) => Row(
///   children: [
///     for (final column in split.columns)
///       Expanded(child: column.child),
///   ],
/// ),
/// ```
final class SplitView extends StatelessWidget {
  /// Created by the router for every build of the split.
  @internal
  const SplitView({
    required this.columns,
    required this.maximumColumns,
    super.key,
  });

  /// The columns on screen, the deepest last. While the split shows a
  /// stack, one [RouteColumn] holding the whole stack. Put each column's
  /// child in the tree exactly once: either this widget or the columns.
  final List<SplitColumn> columns;

  /// How many columns fit, as the split's `maximumColumns` answered for
  /// its size.
  final int maximumColumns;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (index, column) in columns.indexed)
        Expanded(
          flex: index == columns.length - 1
              ? math.max(1, maximumColumns - columns.length + 1)
              : 1,
          child: column.child,
        ),
    ],
  );
}
