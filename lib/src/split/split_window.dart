import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/split/split_part.dart';
import 'package:typed_navigator/src/split/split_presentation.dart';

/// Which parts of a split's stack show where while it shows columns: the
/// columns on screen, the parts before them kept offstage, the placeholder of
/// the top column, and the cover layer from the first cover part on. The first
/// part is always a column: a cover needs columns to cover.
///
/// Compared by identity: it is made for one build.
final class SplitWindow {
  /// Lays out [parts], bottom to top, in at most [columns] columns.
  factory SplitWindow(List<SplitPart> parts, int columns) {
    final coverStart = parts.indexWhere(
      (part) => part.presentation == SplitPresentation.cover,
      1,
    );
    final columned = coverStart < 0 ? parts : parts.sublist(0, coverStart);
    final covers = coverStart < 0 ? <SplitPart>[] : parts.sublist(coverStart);
    final placeholder = columned.lastOrNull?.placeholder;
    final routeColumns = placeholder == null ? columns : columns - 1;
    final shown = math.min(columned.length, routeColumns);
    final hiddenCount = columned.length - shown;
    return SplitWindow._(
      List.unmodifiable(columned.take(hiddenCount)),
      List.unmodifiable(columned.skip(hiddenCount)),
      placeholder,
      List.unmodifiable(covers),
    );
  }

  SplitWindow._(this.hidden, this.shown, this.placeholder, this.covers);

  /// The parts before the columns on screen, kept alive offstage.
  final List<SplitPart> hidden;

  /// The parts in columns on screen, the deepest last.
  final List<SplitPart> shown;

  /// The placeholder of the deepest column, in the column after it.
  final Widget? placeholder;

  /// The parts over the whole split, bottom to top.
  final List<SplitPart> covers;

  /// The column the back button and the back gesture go to.
  SplitPart? get deepest => shown.lastOrNull;

  @override
  String toString() =>
      'SplitWindow(hidden: $hidden, shown: $shown, covers: $covers)';
}
