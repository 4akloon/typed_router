import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/after_build.dart';
import 'package:typed_navigator/src/split/column_back.dart';
import 'package:typed_navigator/src/split/column_back_scope.dart';

/// Gives a page in a split column that is not the deepest its back button:
/// while [ColumnBackScope] above says back closes the column, the page's route
/// holds a [LocalHistoryEntry] that implies an app bar's back button; popping
/// it closes the column and the columns to its right.
///
/// The entry leaves without closing anything when the column becomes the
/// deepest, the split shows a stack, or the page leaves. The app's own
/// local history already on the route goes first: the entry waits until
/// it is gone, since a route pops its newest entry first. Popping the entry
/// asks the pages on screen to the right first ([ColumnClosing]); when it
/// closes, it tells the page's `PopScope` it popped, as `Navigator.pop`
/// does. The
/// column's page is the first in its navigator, so Flutter gives it no back
/// gesture: the gesture still goes to the deepest column only.
final class ColumnBackEntry extends StatefulWidget {
  /// Creates the entry's holder around [child], a page's content.
  const ColumnBackEntry({required this.child, super.key});

  /// The page's content.
  final Widget child;

  @override
  State<ColumnBackEntry> createState() => _ColumnBackEntryState();
}

final class _ColumnBackEntryState extends State<ColumnBackEntry> {
  ModalRoute<Object?>? _route;
  ColumnBack? _back;
  LocalHistoryEntry? _entry;
  ModalRoute<Object?>? _entryRoute;
  late final AfterBuild _sync = AfterBuild(_syncEntry);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context);
    _back = context.dependOnInheritedWidgetOfExactType<ColumnBackScope>()?.back;
    _sync.request(isWanted: () => mounted);
  }

  @override
  void dispose() {
    _withdraw();
    super.dispose();
  }

  /// Puts the entry on the route that should hold it now, or takes it off.
  void _syncEntry() {
    final wanted = switch ((_back, _route)) {
      (final back?, final route?) when back.holdsEntryOn(route) => route,
      _ => null,
    };
    if (wanted == _entryRoute) return;
    _withdraw();
    // The route pops its newest entry first; the app's own go before ours.
    // When they leave, the route's canPop changes and this runs again.
    if (wanted == null || wanted.willHandlePopInternally) return;
    late final LocalHistoryEntry entry;
    entry = LocalHistoryEntry(onRemove: () => _popped(entry));
    wanted.addLocalHistoryEntry(entry);
    _entry = entry;
    _entryRoute = wanted;
  }

  /// Takes the entry off without closing the column. A route already gone
  /// (the column's navigator left with the projection) keeps it.
  void _withdraw() {
    if ((_entry, _entryRoute) case (final entry?, final route?)) {
      _entry = null;
      _entryRoute = null;
      if (route.isActive) route.removeLocalHistoryEntry(entry);
    }
  }

  /// The route popped [entry]: does the back of its page, unless it was
  /// withdrawn. When the page stays (a page to the right refused), the
  /// route's `canPop` changed with the entry gone, so
  /// [didChangeDependencies] puts it back.
  void _popped(LocalHistoryEntry entry) {
    if (!identical(entry, _entry)) return;
    final route = _entryRoute;
    _entry = null;
    _entryRoute = null;
    if ((_back, route) case (final back?, final route?)) back.popped(route);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
