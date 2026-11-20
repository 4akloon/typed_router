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
  /// route is [route] with its screen keyed [topScreenKey].
  const SplitPart({
    required this.owner,
    required this.page,
    required this.route,
    required this.topScreenKey,
    this.presentation = SplitPresentation.column,
    this.placeholderIn,
  });

  /// The entry or the nested level this part stands for; its column
  /// navigator is keyed by it.
  final ColumnOwner owner;

  /// The page of the part.
  final Page<Object?> page;

  /// The top route of the part.
  final TypedRoute<Object?> route;

  /// Keys the screen of the part's top route: closing a column to the left asks
  /// it first.
  final GlobalKey topScreenKey;

  /// How the part shows while the split shows columns.
  final SplitPresentation presentation;

  /// Builds the placeholder shown after this part when it is the top one, in
  /// the split's context; `null`, or answering `null`, for none.
  final Widget? Function(BuildContext context)? placeholderIn;

  @override
  String toString() => 'SplitPart($route)';
}
