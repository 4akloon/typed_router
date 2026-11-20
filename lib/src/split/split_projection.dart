import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/after_build.dart';
import 'package:typed_navigator/src/split/pageless_columns.dart';
import 'package:typed_navigator/src/split/split_layout.dart';
import 'package:typed_navigator/src/split/split_part.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/state/shell_level.dart';

/// Shows a split's stack for the split's size: one navigator with every part as
/// a page while `maximumColumns` is below 2; otherwise a navigator holding the
/// row of columns and the cover pages, each column a navigator of its own keyed
/// by its part, so a screen never changes navigator while the columns shift
///.
///
/// It follows the pageless routes of its columns: while one lies left of the
/// deepest column, that one keeps the back gesture away.
final class SplitProjection extends StatefulWidget {
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

  /// Makes the page under the deepest column's page, showing what takes the
  /// column's place after back.
  final Page<Object?> Function(Widget child) blankPage;

  /// Makes the page holding the row of columns.
  final Page<Object?> Function(Widget row) rowPage;

  /// Called with a page the stack's or the columns' navigator removed.
  final void Function(Page<Object?> page) onDidRemovePage;

  /// Called with a page a column's navigator removed: that column closes with
  /// every one to its right.
  final void Function(Page<Object?> page, SplitEntry split) onDidRemoveColumn;

  @override
  State<SplitProjection> createState() => _SplitProjectionState();
}

final class _SplitProjectionState extends State<SplitProjection> {
  static const _pageless = PagelessColumns();
  List<NavigatorState> _pagelessColumns = const [];
  bool _holdsPageless = false;
  int? _shownColumns;
  late final AfterBuild _refresh = AfterBuild(_readPageless);
  late final AfterBuild _switch = AfterBuild(_closePagelessAndSwitch);

  /// Reads which navigators hold a pageless route; rebuilds when the
  /// columns left of the deepest change from none to some or back.
  void _readPageless() {
    _holdsPageless = _pageless.isAnyOpen(widget.split, widget.state);
    final next = _pageless.rightmostFirst(widget.split, widget.state);
    if (next.isEmpty == _pagelessColumns.isEmpty) return;
    setState(() => _pagelessColumns = next);
  }

  /// Closes the pageless routes the change of projection would lose, then lets
  /// it happen.
  void _closePagelessAndSwitch() {
    _pageless.closeAll(widget.split, widget.state);
    setState(() => _holdsPageless = false);
  }

  /// The columns to show for [wanted]: the shown ones for one more frame
  /// while a change between a stack and columns would lose pageless routes.
  int _columnsFor(int wanted) {
    final shown = _shownColumns;
    if (shown != null && (shown < 2) != (wanted < 2) && _holdsPageless) {
      _switch.request(isWanted: () => mounted);
      return shown;
    }
    return _shownColumns = wanted;
  }

  @override
  Widget build(BuildContext context) {
    final layout = SplitLayout(
      widget.split,
      widget.state,
      widget.parts,
      blankPage: widget.blankPage,
      rowPage: widget.rowPage,
      onDidRemovePage: widget.onDidRemovePage,
      onDidRemoveColumn: widget.onDidRemoveColumn,
    );
    // A navigator inside dispatches one whenever its history changes, a
    // pageless route pushed or popped included.
    return NotificationListener<NavigationNotification>(
      onNotification: (notification) {
        _refresh.request(isWanted: () => mounted);
        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = _columnsFor(
            widget.split.node.columnsFor(constraints.biggest),
          );
          return columns < 2
              ? layout.stack(context)
              : layout.columns(context, columns, _pagelessColumns);
        },
      ),
    );
  }
}
