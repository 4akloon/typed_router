import 'package:flutter/widgets.dart';

/// What owns a column navigator of a split: the entry of a route, or a shell,
/// split or tabs instance nested right inside the split. The same owner keeps
/// the same navigator while it stays in the split, wherever its column moves.
abstract interface class ColumnOwner {
  /// Keys the content of the page the owner shows in its column: while that
  /// page is not current, a pageless route lies over it.
  GlobalKey get pageContentKey;
}
