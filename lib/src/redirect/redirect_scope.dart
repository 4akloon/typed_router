import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/redirect/router_mount.dart';

/// The root of the router's delegate: gives the redirects their context and
/// re-checks the stack when the router is shown and when an inherited widget a
/// redirect depends on changes.
///
/// Its context sees what the `Router`'s does: the widgets above the app and
/// what `WidgetsApp` puts above the `Router`. It builds the navigator through
/// [builder] on every build, so a re-check in [State.didChangeDependencies]
/// shows in the same frame.
final class RedirectScope extends StatefulWidget {
  /// Creates the scope of one router; key it by the router, so another
  /// router gets a scope of its own.
  const RedirectScope({
    required this.mount,
    required this.recheckWhileBuilding,
    required this.builder,
    super.key,
  });

  /// Where the context is attached while the scope is in the tree.
  final RouterMount mount;

  /// Runs the redirects over the whole stack during the build.
  final VoidCallback recheckWhileBuilding;

  /// Builds the navigator from the router's current state.
  final WidgetBuilder builder;

  @override
  State<RedirectScope> createState() => _RedirectScopeState();
}

final class _RedirectScopeState extends State<RedirectScope> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.mount.attach(context);
    widget.recheckWhileBuilding();
  }

  @override
  void dispose() {
    widget.mount.detach(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
