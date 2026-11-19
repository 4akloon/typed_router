import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/split/split_presentation.dart';
import 'package:typed_navigator/src/state/column_owner.dart';

/// One part of a split's stack: a route, or a level nested right inside the
/// split; a column while the split shows columns.
///
/// Compared by identity: it holds a page made for one build.
final class SplitPart {
  /// Creates the part [owner] stands for, shown by [page], whose top
  /// route is [route].
  const SplitPart({
    required this.owner,
    required this.page,
    required this.route,
    this.presentation = SplitPresentation.column,
    this.placeholder,
  });

  /// The entry or the nested level this part stands for; its column
  /// navigator is keyed by it.
  final ColumnOwner owner;

  /// The page of the part.
  final Page<Object?> page;

  /// The top route of the part.
  final TypedRoute<Object?> route;

  /// How the part shows while the split shows columns.
  final SplitPresentation presentation;

  /// The placeholder shown after this part when it is the top one.
  final Widget? placeholder;

  @override
  String toString() => 'SplitPart($route)';
}
