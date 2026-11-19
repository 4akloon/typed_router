import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/nested_navigator.dart';
import 'package:typed_navigator/src/split/split_column.dart';
import 'package:typed_navigator/src/split/split_part.dart';
import 'package:typed_navigator/src/split/split_view.dart';
import 'package:typed_navigator/src/split/split_window.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';

/// Shows a split's stack for the split's size: one navigator with every part as
/// a page while `maximumColumns` is below 2; otherwise a navigator holding the
/// row of columns and the cover pages, each column a navigator of its own keyed
/// by its part, so a screen never changes navigator while the columns shift
///.
final class SplitProjection extends StatelessWidget {
  /// Creates the projection of [split]'s [parts], bottom to top.
  const SplitProjection({
    required this.split,
    required this.state,
    required this.parts,
    required this.blankPage,
    required this.rowPage,
    required this.onDidRemovePage,
    required this.onDidRemoveColumn,
    super.key,
  });

  /// The split instance.
  final SplitEntry split;

  /// The router's whole state, for the split's builder.
  final NavigationState state;

  /// The parts of the split's stack, bottom to top. At least one.
  final List<SplitPart> parts;

  /// The empty page under the page of a column whose route can pop.
  final Page<Object?> blankPage;

  /// Makes the page holding the row of columns.
  final Page<Object?> Function(Widget row) rowPage;

  /// Called with a page the stack's or the columns' navigator removed.
  final void Function(Page<Object?> page) onDidRemovePage;

  /// Called with a page a column's navigator removed: that column closes with
  /// every one to its right.
  final void Function(Page<Object?> page, SplitEntry split) onDidRemoveColumn;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = split.node.columnsFor(constraints.biggest);
      return columns < 2 ? _stack(context) : _columns(context, columns);
    },
  );

  Widget _stack(BuildContext context) {
    final navigator = NestedNavigator(
      navigatorKey: split.navigatorKey,
      pages: [for (final part in parts) part.page],
      onDidRemovePage: onDidRemovePage,
      isActive: true,
    );
    final view = SplitView(
      columns: [RouteColumn(parts.last.route, navigator)],
      maximumColumns: 1,
    );
    return _frame(context, view);
  }

  Widget _columns(BuildContext context, int columns) {
    final window = SplitWindow(parts, columns);
    final view = SplitView(
      columns: [
        for (final part in window.shown)
          RouteColumn(
            part.route,
            _columnNavigator(part, isActive: part == window.deepest),
          ),
        if ((window.deepest, window.placeholder) case (
          final deepest?,
          final placeholder?,
        ))
          PlaceholderColumn(
            deepest.route,
            Semantics(container: true, child: placeholder),
          ),
      ],
      maximumColumns: columns,
    );
    final row = Stack(
      fit: StackFit.expand,
      children: [
        for (final part in window.hidden)
          Offstage(
            child: TickerMode(
              enabled: false,
              child: _columnNavigator(part, isActive: false),
            ),
          ),
        Builder(builder: (context) => _frame(context, view)),
      ],
    );
    return NestedNavigator(
      navigatorKey: split.columnsNavigatorKey,
      pages: [rowPage(row), for (final part in window.covers) part.page],
      onDidRemovePage: onDidRemovePage,
      isActive: true,
    );
  }

  /// The split's builder around [view], keyed so it keeps its state when
  /// the projection changes.
  Widget _frame(BuildContext context, SplitView view) => KeyedSubtree(
    key: split.frameKey,
    child: split.node.frame(context, state, view),
  );

  /// The navigator of [part]'s column: its page alone, so it cannot pop and
  /// shows no back button, except in the deepest column ([isActive]), where an
  /// empty page under it lets back and the back gesture close it; the split's
  /// first part never can.
  Widget _columnNavigator(SplitPart part, {required bool isActive}) =>
      NestedNavigator(
        navigatorKey: split.columnKeyOf(part.owner),
        pages: [if (isActive && part != parts.first) blankPage, part.page],
        onDidRemovePage: (page) => onDidRemoveColumn(page, split),
        isActive: isActive,
      );
}
