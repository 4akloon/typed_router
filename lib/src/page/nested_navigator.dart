import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/on_screen_level.dart';
import 'package:typed_navigator/src/split/column_back_scope.dart';
import 'package:typed_navigator/src/split/column_closing.dart';

/// A navigator nested in a page: a shell's, a branch's, a split's or one
/// column's. It tells the pages in it whether it is on screen and whether back
/// from them closes a split column, and is a semantics boundary, as
/// go_router's: without it, the barrier of a route in this navigator drops what
/// was painted before it.
final class NestedNavigator extends StatelessWidget {
  /// Creates the navigator keyed [navigatorKey] showing [pages]; [isActive]
  /// when it is shown (see [OnScreenLevel.isActive]).
  const NestedNavigator({
    required this.navigatorKey,
    required this.pages,
    required this.onDidRemovePage,
    required this.isActive,
    this.columnClosing,
    super.key,
  });

  /// The key of the navigator.
  final GlobalKey<NavigatorState> navigatorKey;

  /// The pages, bottom to top.
  final List<Page<Object?>> pages;

  /// Called with a page the navigator removed by itself.
  final void Function(Page<Object?> page) onDidRemovePage;

  /// Whether this navigator is the one shown at its place.
  final bool isActive;

  /// How back from this navigator's page closes the split column it shows
  /// (see [ColumnBackScope]); `null` for every other navigator.
  final ColumnClosing? columnClosing;

  @override
  Widget build(BuildContext context) => OnScreenLevel(
    isActive: isActive,
    child: Semantics(
      container: true,
      explicitChildNodes: true,
      child: ColumnBackScope(
        closing: columnClosing,
        child: Navigator(
          key: navigatorKey,
          pages: pages,
          onDidRemovePage: onDidRemovePage,
        ),
      ),
    ),
  );
}
