import 'package:flutter/widgets.dart';
import 'package:typed_router/src/exit/exit_pop_entry.dart';
import 'package:typed_router/src/exit/last_page_exit.dart';
import 'package:typed_router/src/exit/page_back.dart';
import 'package:typed_router/src/router/typed_router.dart';
import 'package:typed_router/src/state/navigation_entry.dart';

/// The content of a page whose node has `onExit`: registers an
/// [ExitPopEntry] with the page's route, so back asks `onExit` through the
/// router instead of the navigator popping the page.
class ExitBackGate extends StatefulWidget {
  /// Creates the gate of [entry]'s page around [child]; on the only page,
  /// back goes to [lastPageExit].
  const ExitBackGate({
    required this.entry,
    required this.lastPageExit,
    required this.child,
    super.key,
  });

  /// The entry shown by the page.
  final NavigationEntry entry;

  /// Asks before back leaves the app from the only page.
  final LastPageExit lastPageExit;

  /// The screen.
  final Widget child;

  @override
  State<ExitBackGate> createState() => _ExitBackGateState();
}

class _ExitBackGateState extends State<ExitBackGate> {
  // The route reads the entry's answer while this page leaves the tree too,
  // when the context may no longer look up the router.
  late final _RouterPageBack _back = _RouterPageBack(widget);
  late final ExitPopEntry _entry = ExitPopEntry(() => context, _back);
  ModalRoute<Object?>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _back.router = TypedRouter.of(context);
    final route = ModalRoute.of(context);
    if (route == _route) return;
    _route?.unregisterPopEntry(_entry);
    _route = route;
    route?.registerPopEntry(_entry);
  }

  @override
  void didUpdateWidget(ExitBackGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    _back.gate = widget;
  }

  @override
  void dispose() {
    _route?.unregisterPopEntry(_entry);
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Back through the router above the gate.
class _RouterPageBack implements PageBack {
  _RouterPageBack(this.gate);

  ExitBackGate gate;
  late TypedRouter router;

  @override
  bool get isOnlyPage => !router.canPop;

  @override
  void pop(Object? result) => router.pop(result);

  @override
  void leaveApp() => gate.lastPageExit.ask(gate.entry, () => router.state);
}
