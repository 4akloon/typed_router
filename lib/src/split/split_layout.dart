import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/nested_navigator.dart';
import 'package:typed_navigator/src/split/column_back.dart';
import 'package:typed_navigator/src/split/column_closing.dart';
import 'package:typed_navigator/src/split/split_column.dart';
import 'package:typed_navigator/src/split/split_part.dart';
import 'package:typed_navigator/src/split/split_view.dart';
import 'package:typed_navigator/src/split/split_window.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';

/// Lays out a split's parts for one build: as one stack navigator, or as a
/// navigator holding the row of columns and the cover pages, each column a
/// navigator of its own keyed by its part.
final class SplitLayout {
  /// Creates the layout of [_split]'s [_parts] in [_state], with the page
  /// under the deepest column from [_blankPage] and the row's page from
  /// [_rowPage]; the navigators
  /// report removed pages to [_onDidRemovePage], the column navigators to
  /// [_onDidRemoveColumn].
  const SplitLayout(
    this._split,
    this._state,
    this._parts, {
    required this._blankPage,
    required this._rowPage,
    required this._onDidRemovePage,
    required this._onDidRemoveColumn,
  });

  final SplitEntry _split;
  final NavigationState _state;
  final List<SplitPart> _parts;
  final Page<Object?> Function(Widget child) _blankPage;
  final Page<Object?> Function(Widget row) _rowPage;
  final void Function(Page<Object?> page) _onDidRemovePage;
  final void Function(Page<Object?> page, SplitEntry split) _onDidRemoveColumn;

  /// Every part as a page of the split's own navigator.
  Widget stack(BuildContext context) {
    final navigator = NestedNavigator(
      navigatorKey: _split.navigatorKey,
      pages: [for (final part in _parts) part.page],
      onDidRemovePage: _onDidRemovePage,
      isActive: true,
    );
    final view = SplitView(
      columns: [RouteColumn(_parts.last.route, navigator)],
      maximumColumns: 1,
    );
    return _frame(context, view);
  }

  /// The parts in at most [columns] columns. While [pagelessColumns] is not
  /// empty, the deepest column keeps the back gesture away: a pageless route to
  /// its left takes it.
  Widget columns(
    BuildContext context,
    int columns,
    List<NavigatorState> pagelessColumns,
  ) {
    final window = SplitWindow(_parts, columns, context);
    final deepestBack = pagelessColumns.isEmpty
        ? null
        : RemovesPage((page) => _onDidRemoveColumn(page, _split));
    Widget column(SplitPart part) =>
        _column(context, part, window, deepestBack);
    final view = SplitView(
      columns: [
        for (final part in window.shown) RouteColumn(part.route, column(part)),
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
          Offstage(child: TickerMode(enabled: false, child: column(part))),
        Builder(builder: (context) => _frame(context, view)),
      ],
    );
    return NestedNavigator(
      navigatorKey: _split.columnsNavigatorKey,
      pages: [_rowPage(row), for (final part in window.covers) part.page],
      onDidRemovePage: _onDidRemovePage,
      isActive: true,
    );
  }

  /// What takes the place of the part at [index] after back: the placeholder of
  /// the part before it, or nothing.
  Widget _placeholderBefore(BuildContext context, int index) =>
      _parts[index - 1].placeholderIn?.call(context) ?? const SizedBox();

  /// The split's builder around [view], keyed so it keeps its state when
  /// the projection changes.
  Widget _frame(BuildContext context, SplitView view) => KeyedSubtree(
    key: _split.frameKey,
    child: _split.node.frame(context, _state, view),
  );

  /// The navigator of [part]'s column in [window]. The deepest column has a
  /// page under its page, so back and the gesture close it, and does
  /// [deepestBack]; a shown column to its left closes through its page's back
  /// button; the first part never does.
  Widget _column(
    BuildContext context,
    SplitPart part,
    SplitWindow window,
    ColumnBack? deepestBack,
  ) {
    final isDeepest = part == window.deepest;
    final index = _parts.indexOf(part);
    return NestedNavigator.column(
      navigatorKey: _split.columnKeyOf(part.owner),
      pages: [
        if (isDeepest && index > 0)
          _blankPage(_placeholderBefore(context, index)),
        part.page,
      ],
      onDidRemovePage: (page) => _onDidRemoveColumn(page, _split),
      isActive: isDeepest,
      columnBack: isDeepest
          ? deepestBack
          : window.closesByBackButton(part)
          ? ClosesColumn(
              ColumnClosing(
                window.screensRightOf(part, _state.entries.last),
                () => _onDidRemoveColumn(part.page, _split),
              ),
            )
          : null,
    );
  }
}
