import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/level_inside.dart';
import 'package:typed_navigator/src/page/level_pop_entry.dart';
import 'package:typed_navigator/src/page/on_screen_scope.dart';

/// The content of a level's page (a shell's or a tabs instance's): registers a
/// [LevelPopEntry] with the page's route, so a back gesture goes inside while
/// something there handles back, and nowhere while the level is off screen.
///
/// The entry reads what is inside again on every `NavigationNotification` from
/// inside (a navigator's history changed, pages or pageless routes, or a page's
/// `PopScope` changed, as the router's own gate does when another branch
/// shows), and when the level's page or its place on screen changes. The
/// notification stops here: the level's page tells the navigator above what the
/// level can pop.
class LevelPopGate extends StatefulWidget {
  /// Creates the gate around [child], the level's frame.
  const LevelPopGate({required this.inside, required this.child, super.key});

  /// What is inside the level for the router's current state.
  final LevelInside inside;

  /// The level's frame with its navigators.
  final Widget child;

  @override
  State<LevelPopGate> createState() => _LevelPopGateState();
}

class _LevelPopGateState extends State<LevelPopGate> {
  // Reads the widget when asked: the router rebuilds it with each state.
  late final LevelPopEntry _entry = LevelPopEntry(() => widget.inside);
  ModalRoute<Object?>? _route;
  bool _isOnScreen = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _route) {
      _route?.unregisterPopEntry(_entry);
      _route = route;
      route?.registerPopEntry(_entry);
    }
    _isOnScreen =
        context
            .dependOnInheritedWidgetOfExactType<OnScreenScope>()
            ?.isOnScreen ??
        true;
    // The level went off or on screen, or its page's route changed. What
    // is inside may change in this frame too; its navigators then notify
    // after the frame, and the listener below reads it again.
    _refresh();
  }

  @override
  void dispose() {
    _route?.unregisterPopEntry(_entry);
    _entry.dispose();
    super.dispose();
  }

  void _refresh() => _entry.refresh(isOnScreen: _isOnScreen);

  @override
  Widget build(BuildContext context) =>
      NotificationListener<NavigationNotification>(
        onNotification: (notification) {
          // Flutter dispatches these after the frame (ModalRoute's
          // _maybeDispatchNavigationNotification), when routes may be read.
          _refresh();
          // The level speaks for what is inside through its page's pop entry; a
          // navigator inside, on screen or in a hidden branch, does not tell
          // the platform on its own.
          return true;
        },
        child: widget.child,
      );
}
