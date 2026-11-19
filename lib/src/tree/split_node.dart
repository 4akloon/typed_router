part of 'tree_node.dart';

/// One stack shown two ways: side by side in columns while the split is wide
/// (rooms | room, or Miller columns), as an ordinary stack while it is narrow;
/// the screens keep their state when the width changes.
///
/// Like a [ShellNode], it is not a route and is transparent for [P]; the
/// routes below it live in its stack, and the state does not depend on the
/// width. Navigation needs no new calls: `go` to a sibling replaces a
/// column, `push` adds the deepest one, back removes the deepest one.
///
/// In columns, every route has a navigator of its own: a pageless route
/// opened from a column stays in it, and `Navigator.pop(context)` in a
/// column closes that column and every one to its right (on a stack it
/// pops the top page, as usual). Only the deepest column can pop
/// (`Navigator.canPop`, an app bar's back button), unless it holds the
/// split's first route; back there goes to the navigator around the split.
/// Changes in columns are instant; a narrow split animates as any stack.
///
/// ```dart
/// SplitNode<NoParentRoute>(
///   maximumColumns: (size) => size.width >= 840 ? 2 : 1,
///   children: [
///     RouteNode<RoomsRoute>(
///       build: (context, rooms) => const RoomsPage(),
///       placeholder: (context, rooms) => const Text('Pick a room'),
///       children: [
///         RouteNode<RoomRoute>(build: (context, room) => RoomPage(room.id))
///             .withParent((room) => const RoomsRoute()),
///       ],
///     ),
///   ],
/// )
/// ```
final class SplitNode<P> extends TreeNode<P> {
  /// Creates a split around [children]; the router throws [ArgumentError]
  /// when it has none.
  const SplitNode({
    required this.maximumColumns,
    required this.children,
    this.builder,
    this.pageFactory,
    this.redirect,
    this.navigatorSlot,
  });

  /// How many columns fit in [size], the split's own box (not the
  /// window's): the last routes of the stack, plus the top route's
  /// placeholder. Below 2, the split shows a stack. Called on every
  /// layout; a negative answer throws [ArgumentError].
  final int Function(Size size) maximumColumns;

  /// The nodes in the split's stack. At least one.
  final List<TreeNode<P>> children;

  /// Builds the frame around [split]: the columns in a row. Lay out
  /// [SplitView.columns] yourself for other widths, dividers or an
  /// animated shift. `null` shows [split] as it is.
  ///
  /// While the split shows columns, a cover route
  /// ([SplitPresentation.cover]) lies over this frame; while it shows a
  /// stack, the frame holds the stack with every page in it. Put what must
  /// stay over every page (a rail, a header) around the split, in a
  /// [ShellNode].
  final Widget Function(
    BuildContext context,
    NavigationState state,
    SplitView split,
  )?
  builder;

  /// Makes the split's own page in the navigator around it; the router's
  /// factory when `null`. The routes below get their own nodes' factories;
  /// the page holding the row of columns comes from the router's factory,
  /// which should make full-screen pages.
  final PageFactory? pageFactory;

  /// Sends a navigation elsewhere before it shows a route of this split's
  /// subtree, like [ShellNode.redirect].
  final TypedRoute<Object?>? Function(
    BuildContext context,
    NavigationState target,
  )?
  redirect;

  /// Names the split's navigator, so routes below can show in it with
  /// `RouteNode.parentNavigatorSlot`. Optional.
  final NavigatorSlot? navigatorSlot;

  /// The number of columns for [size]; throws [ArgumentError] when
  /// [maximumColumns] answers a negative number.
  @internal
  int columnsFor(Size size) {
    final columns = maximumColumns(size);
    if (columns < 0) {
      throw ArgumentError.value(
        columns,
        'maximumColumns',
        'maximumColumns returned $columns for $size. Return 0 or 1 for a '
            'stack, 2 or more for columns.',
      );
    }
    return columns;
  }

  /// Frames [split] with [builder], or shows it as it is.
  @internal
  Widget frame(BuildContext context, NavigationState state, SplitView split) =>
      switch (builder) {
        final builder? => builder(context, state, split),
        null => split,
      };

  /// Runs [redirect] for [target], or lets it through when there is none.
  @internal
  TypedRoute<Object?>? redirectFor(
    BuildContext context,
    NavigationState target,
  ) => redirect?.call(context, target);

  /// This node's [pageFactory], or [routerFactory] when it has none.
  @internal
  PageFactory pageFactoryOr(PageFactory routerFactory) =>
      pageFactory ?? routerFactory;
}
