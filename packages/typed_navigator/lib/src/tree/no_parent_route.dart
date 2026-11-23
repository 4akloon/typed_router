/// Marks the place in the route tree where no route is above a node.
///
/// The top level of the router is a `List<TreeNode<NoParentRoute>>`, and so
/// will be the inside of shells and tab branches. A plain `RouteNode` is a
/// `TreeNode<NoParentRoute>`, so it can only sit where no route is above
/// it. Under a route, a node is put with `RouteNode.withParent` instead.
///
/// Never instantiated: it exists only as a type argument. Final, so no
/// route type of the app can implement it and pass a node that has a
/// parent off as a top-level one (`TreeNode` is covariant in its parent).
abstract final class NoParentRoute {}
