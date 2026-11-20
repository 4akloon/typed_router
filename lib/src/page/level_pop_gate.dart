import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/after_build.dart';
import 'package:typed_navigator/src/page/level_inside.dart';
import 'package:typed_navigator/src/page/level_pop_entry.dart';
import 'package:typed_navigator/src/page/on_screen_scope.dart';
import 'package:typed_navigator/src/split/column_back_scope.dart';

/// The content of a level's page (a shell's, a tabs instance's, a split's):
/// registers a [LevelPopEntry] with the page's route, so a back gesture goes
/// inside while something there handles back, and nowhere while the level is
/// off screen.
///
/// The entry reads what is inside again on every `NavigationNotification`
/// from inside (a navigator's history changed, pages or pageless routes,
/// or a page's `PopScope` changed, as the router's own gate does when
/// another branch shows), and when the level's page or its place on
/// screen changes.
final class LevelPopGate extends StatefulWidget {
  /// Creates the gate around [child], the level's frame.
  const LevelPopGate({required this.inside, required this.child, super.key});

  /// What is inside the level for the router's current state.
  final LevelInside inside;

  /// The level's frame with its navigators.
  final Widget child;

  @override
  State<LevelPopGate> createState() => _LevelPopGateState();
}

final class _LevelPopGateState extends State<LevelPopGate> {
  // Reads the widget when asked: the router rebuilds it with each state.
  late final LevelPopEntry _entry = LevelPopEntry(() => widget.inside);
  ModalRoute<Object?>? _route;
  bool _isOnScreen = true;
  late final AfterBuild _refresh = AfterBuild(
    () => _entry.refresh(isOnScreen: _isOnScreen),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _route) {
      _route?.unregisterPopEntry(_entry);
      _route = route;
      route?.registerPopEntry(_entry);
    }
    // A level whose back button closes its split column counts as on screen for
    // maybePop; as the first page of its column's navigator, it gets no back
    // gesture.
    final closesColumn =
        context
            .dependOnInheritedWidgetOfExactType<ColumnBackScope>()
            ?.closing !=
        null;
    _isOnScreen =
        closesColumn ||
        (context
                .dependOnInheritedWidgetOfExactType<OnScreenScope>()
                ?.isOnScreen ??
            true);
    // A gate made or moved next to navigators that already exist (a level's
    // page moving between a split's navigators) hears nothing from them.
    _refresh.request(isWanted: () => mounted);
  }

  @override
  void dispose() {
    _route?.unregisterPopEntry(_entry);
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<NavigationNotification>(
        onNotification: (notification) {
          _refresh.request(isWanted: () => mounted);
          return false;
        },
        child: widget.child,
      );
}
