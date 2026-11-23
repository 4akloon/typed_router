import 'package:flutter/widgets.dart';

/// Carries the flight path of the app's hero controller past the root
/// navigator, which hides the app's `HeroControllerScope` from its pages:
/// nested navigators fly heroes along the same path as the root one, an arc in
/// a `MaterialApp`.
class HeroFlightScope extends InheritedWidget {
  /// Creates the scope with the app's [createRectTween] above [child].
  const HeroFlightScope({
    required this.createRectTween,
    required super.child,
    super.key,
  });

  /// The app's flight path; `null` for a straight line.
  final CreateRectTween? createRectTween;

  /// Nested controllers keep the path they were made with, as go_router's.
  @override
  bool updateShouldNotify(HeroFlightScope oldWidget) => false;
}
