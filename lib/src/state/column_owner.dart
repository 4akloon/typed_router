/// What owns a column navigator of a split: the entry of a route, or a shell,
/// split or tabs instance nested right inside the split. The same owner keeps
/// the same navigator while it stays in the split, wherever its column moves.
abstract interface class ColumnOwner {}
