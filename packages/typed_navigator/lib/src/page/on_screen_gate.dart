import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/on_screen_scope.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';

/// The content of a route's page: lets a back gesture through only while the
/// page is on screen, and hands a native `Navigator.pop(context, result)` to
/// [entry].
///
/// A page whose navigator is off screen (in a covered shell, in a branch
/// not shown) says it cannot pop, so Flutter does not give it the gesture;
/// router operations and `Navigator.pop` still remove it. On screen, the
/// app's own `PopScope` decides.
class OnScreenGate extends StatelessWidget {
  /// Creates the gate of [entry]'s page around [child].
  const OnScreenGate({required this.entry, required this.child, super.key});

  /// The entry shown by the page.
  final NavigationEntry entry;

  /// The screen.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isNavigatorOnScreen =
        context
            .dependOnInheritedWidgetOfExactType<OnScreenScope>()
            ?.isOnScreen ??
        true;
    // Within its own navigator Flutter already gives the gesture only to
    // the current route; the gate covers the navigators around it.
    return PopScope<Object?>(
      canPop: isNavigatorOnScreen,
      // The navigator reports a native Navigator.pop(context, result) here,
      // just before onDidRemovePage; Route.popped would arrive too late.
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) entry.offerNativeResult(result);
      },
      child: child,
    );
  }
}
