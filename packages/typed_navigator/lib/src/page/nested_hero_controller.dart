import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/hero_flight_scope.dart';

/// Gives one nested navigator (a shell's, a branch's) a hero controller of its
/// own, as go_router does: a navigator hides the app's controller from the
/// navigators inside it, and one controller cannot serve two navigators. The
/// controller follows the app's flight path ([HeroFlightScope]) and is disposed
/// with the navigator; keyed by the navigator's level, it moves with the
/// navigator in the tree.
class NestedHeroController extends StatefulWidget {
  /// Creates the controller's holder around [child], the nested navigator.
  const NestedHeroController({required this.child, super.key});

  /// The nested navigator.
  final Widget child;

  @override
  State<NestedHeroController> createState() => _NestedHeroControllerState();
}

class _NestedHeroControllerState extends State<NestedHeroController> {
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
