import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/on_screen_level.dart';

/// A navigator nested in a page: a shell's, a branch's, a split's or one
/// column's. It tells the pages in it whether it is on screen and is a
/// semantics boundary, as go_router's: without it, the barrier of a route in
/// this navigator drops what was painted before it.
final class NestedNavigator extends StatelessWidget {
  /// Creates the navigator keyed [navigatorKey] showing [pages]; [isActive]
  /// when it is shown (see [OnScreenLevel.isActive]).
  const NestedNavigator({
    required this.navigatorKey,
    required this.pages,
    required this.onDidRemovePage,
    required this.isActive,
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

  @override
  Widget build(BuildContext context) => OnScreenLevel(
    isActive: isActive,
    child: Semantics(
      container: true,
      explicitChildNodes: true,
      child: Navigator(
        key: navigatorKey,
        pages: pages,
        onDidRemovePage: onDidRemovePage,
      ),
    ),
  );
}
