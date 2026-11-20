import 'package:flutter/widgets.dart';
import 'package:typed_navigator/typed_navigator.dart';

/// A page factory of the app's own: screens fade in instead of sliding.
final class FadePageFactory implements PageFactory {
  const FadePageFactory();

  @override
  Page<Object?> createPage(PageRequest request) =>
      _FadePage(key: request.key, name: request.name, child: request.child);
}

/// A page that fades its [child] in and out.
final class _FadePage extends Page<Object?> {
  const _FadePage({required this.child, super.key, super.name});

  final Widget child;

  @override
  Route<Object?> createRoute(BuildContext context) => _FadeRoute(this);
}

/// Shows the child of the page it holds now, not the one it was created
/// with: the router updates pages in place (see `PageFactory`).
final class _FadeRoute extends PageRoute<Object?> {
  _FadeRoute(_FadePage page) : super(settings: page);

  _FadePage get _page => settings as _FadePage;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => _page.child;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => FadeTransition(opacity: animation, child: child);
}
