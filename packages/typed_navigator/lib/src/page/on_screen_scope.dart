import 'package:flutter/widgets.dart';

/// Whether the navigator below is on screen: its shell's or branch's page is
/// current all the way up, and its branch is active. Without a scope above, a
/// navigator is on screen (the root).
class OnScreenScope extends InheritedWidget {
  /// Creates the scope for the navigator in [child].
  const OnScreenScope({
    required this.isOnScreen,
    required super.child,
    super.key,
  });

  /// Whether the navigator below is on screen.
  final bool isOnScreen;

  @override
  bool updateShouldNotify(OnScreenScope oldWidget) =>
      oldWidget.isOnScreen != isOnScreen;
}
