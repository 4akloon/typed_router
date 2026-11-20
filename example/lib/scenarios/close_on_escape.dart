import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Esc goes back, as the system back button does: in a split it closes a sheet
/// in a column first, then the deepest column.
///
/// The library leaves Esc to the app, as Navigator does for pages. The
/// intent is our own: Flutter's `DismissIntent` stops at the page route's
/// dismiss action, which is disabled for pages.
final class CloseOnEscape extends StatelessWidget {
  const CloseOnEscape({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Shortcuts(
    shortcuts: const {
      SingleActivator(LogicalKeyboardKey.escape): _GoBackIntent(),
    },
    child: Actions(
      actions: {
        _GoBackIntent: CallbackAction<_GoBackIntent>(
          onInvoke: (intent) => Router.of(context).routerDelegate.popRoute(),
        ),
      },
      child: child,
    ),
  );
}

final class _GoBackIntent extends Intent {
  const _GoBackIntent();
}
