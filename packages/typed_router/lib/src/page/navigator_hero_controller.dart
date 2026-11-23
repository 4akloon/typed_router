import 'package:flutter/widgets.dart';
import 'package:typed_router/src/page/hero_flight_scope.dart';

/// Gives one navigator a hero controller of its own, as go_router does: a
/// nested navigator, since a navigator hides the app's controller from the
/// navigators inside it and one controller cannot serve two navigators; and the
/// root navigator when the app gives none, as in a `WidgetsApp`. The controller
/// follows the app's flight path ([HeroFlightScope]) and is disposed with the
/// navigator; keyed by a nested navigator's level, it moves with the navigator
/// in the tree.
class NavigatorHeroController extends StatefulWidget {
  /// Creates the controller's holder around [child], the navigator.
  const NavigatorHeroController({required this.child, super.key});

  /// The navigator.
  final Widget child;

  @override
  State<NavigatorHeroController> createState() =>
      _NavigatorHeroControllerState();
}

class _NavigatorHeroControllerState extends State<NavigatorHeroController> {
  // Made on first build with the app's flight path, which stays fixed for
  // the controller's life.
  late final HeroController _controller = HeroController(
    createRectTween: context
        .getInheritedWidgetOfExactType<HeroFlightScope>()
        ?.createRectTween,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      HeroControllerScope(controller: _controller, child: widget.child);
}
