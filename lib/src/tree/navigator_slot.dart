/// Names a navigator in the route tree, like a navigator key in go_router, so a
/// route can show in it rather than in the nearest one.
///
/// Give a slot to a `ShellNode` or a `BranchNode` (`navigatorSlot`), then
/// to the routes below it that should show in its navigator
/// (`RouteNode.parentNavigatorSlot`). [root] is the router's root
/// navigator. A slot is not a `GlobalKey`: every instance of a shell on the
/// stack has its own navigator, and the slot names them all. Compared by
/// identity.
///
/// ```dart
/// RouteNode<CreateRoomRoute>(
///   parentNavigatorSlot: NavigatorSlot.root, // above the tabs
///   build: (context, route) => const CreateRoomPage(),
/// )
/// ```
final class NavigatorSlot {
  /// A new slot, for one `ShellNode` or `BranchNode`.
  NavigatorSlot();

  /// The router's root navigator.
  static final NavigatorSlot root = NavigatorSlot();

  @override
  String toString() =>
      identical(this, root) ? 'NavigatorSlot.root' : 'NavigatorSlot()';
}
