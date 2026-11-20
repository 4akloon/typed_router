import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/on_screen_level.dart';
import 'package:typed_navigator/src/split/column_back.dart';
import 'package:typed_navigator/src/split/column_back_scope.dart';

/// A navigator nested in a page: a shell's, a branch's, a split's or one
/// column's. It tells the pages in it whether it is on screen and what back
/// from them does in a split, and is a semantics boundary, as go_router's:
/// without it, the barrier of a route in this navigator drops what was painted
/// before it.
final class NestedNavigator extends StatelessWidget {
  /// Creates the navigator keyed [navigatorKey] showing [pages]; [isActive]
  /// when it is shown (see [OnScreenLevel.isActive]). Back from its pages
  /// follows the navigator around it: when that one's pages have a
  /// [ColumnBack], these remove themselves ([RemovesPage]).
  const NestedNavigator({
    required this.navigatorKey,
    required this.pages,
    required this.onDidRemovePage,
    required this.isActive,
    super.key,
  }) : _isColumn = false,
       _columnBack = null;

  /// Creates the navigator of a split column, whose pages do [columnBack]
  /// on back, whatever the navigator around it does.
  const NestedNavigator.column({
    required this.navigatorKey,
    required this.pages,
    required this.onDidRemovePage,
    required this.isActive,
    required this._columnBack,
    super.key,
  }) : _isColumn = true;

  /// The key of the navigator.
  final GlobalKey<NavigatorState> navigatorKey;

  /// The pages, bottom to top.
  final List<Page<Object?>> pages;

  /// Called with a page the navigator removed by itself.
  final void Function(Page<Object?> page) onDidRemovePage;

  /// Whether this navigator is the one shown at its place.
  final bool isActive;

  final bool _isColumn;
  final ColumnBack? _columnBack;

  /// What back from the pages does, given the navigator around this one.
  ColumnBack? _backIn(BuildContext context) {
    if (_isColumn) return _columnBack;
    final outer = context
        .dependOnInheritedWidgetOfExactType<ColumnBackScope>()
        ?.back;
    return outer == null ? null : RemovesPage(onDidRemovePage);
  }

  @override
  Widget build(BuildContext context) => OnScreenLevel(
    isActive: isActive,
    child: Semantics(
      container: true,
      explicitChildNodes: true,
      child: ColumnBackScope(
        back: _backIn(context),
        child: Navigator(
          key: navigatorKey,
          pages: pages,
          onDidRemovePage: onDidRemovePage,
        ),
      ),
    ),
  );
}
