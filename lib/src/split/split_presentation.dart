/// How a route shows inside a `SplitNode` while the split shows columns; set on
/// its `RouteNode.splitPresentation`.
///
/// While the split shows a stack (a narrow window), every route is a page
/// of that stack whatever its presentation.
enum SplitPresentation {
  /// A column of its own, next to the routes below it. The default.
  column,

  /// A layer over the whole split, the columns kept alive underneath; the
  /// routes above it join the layer. Back reveals the columns as they
  /// were. For a page over the whole app instead, use
  /// `RouteNode.parentNavigatorSlot: NavigatorSlot.root`.
  cover,
}
