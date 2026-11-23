import 'package:flutter/widgets.dart';
import 'package:typed_router/src/page/on_screen_scope.dart';

/// Tells the navigator of a shell or of a branch of tabs whether it is on
/// screen: the scope above says so, the page holding it is the current route of
/// its own navigator, and, for a branch, the branch is [isActive].
///
/// `ModalRoute.of` makes it rebuild when a route opens or closes above
/// that page, so a dialog over a shell takes the back gesture itself.
class OnScreenLevel extends StatelessWidget {
  /// Creates the level around [child], the nested navigator.
  const OnScreenLevel({required this.isActive, required this.child, super.key});

  /// Whether this level is shown: always for a shell, the active branch of
  /// tabs.
  final bool isActive;

  /// The nested navigator.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isAboveOnScreen =
        context
            .dependOnInheritedWidgetOfExactType<OnScreenScope>()
            ?.isOnScreen ??
        true;
    final isPageCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    return OnScreenScope(
      isOnScreen: isAboveOnScreen && isPageCurrent && isActive,
      child: child,
    );
  }
}
