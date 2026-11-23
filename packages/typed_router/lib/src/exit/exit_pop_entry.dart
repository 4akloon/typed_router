import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:typed_router/src/exit/page_back.dart';

/// The pop entry of a page whose node has `onExit`: the page never lets a pop
/// through, as `PopScope(canPop: false)`, so the back gesture neither previews
/// nor swipes it away; a refused pop goes to [_back], which asks `onExit`.
///
/// The page's own `PopScope` decides first, as in go_router (where a pop it
/// refuses never reaches `onExit`): before going on, the entry reads the
/// route's disposition as if it let the pop through, and stays silent when
/// another entry still refuses.
class ExitPopEntry extends PopEntry<Object?> {
  /// Creates the entry of the page under [_context]; [_back] pops the page or
  /// leaves the app.
  ExitPopEntry(this._context, this._back);

  final BuildContext Function() _context;
  final PageBack _back;
  final _ExitCanPop _canPop = _ExitCanPop();

  @override
  ValueListenable<bool> get canPopNotifier => _canPop;

  @override
  void onPopInvokedWithResult(bool didPop, Object? result) {
    // A native Navigator.pop skips PopScope and onExit alike.
    if (didPop) return;
    final disposition = _canPop.whileLettingThrough(
      () => ModalRoute.popDispositionOf(_context()),
    );
    if (disposition == RoutePopDisposition.doNotPop) return;
    if (_back.isOnlyPage) return _back.leaveApp();
    _back.pop(result);
  }

  /// Releases the listeners of the route.
  void dispose() => _canPop.dispose();
}

/// Whether the page lets a pop through: only while the entry looks past
/// itself. Read when asked; it never notifies.
class _ExitCanPop extends ChangeNotifier implements ValueListenable<bool> {
  bool _isLettingThrough = false;

  @override
  bool get value => _isLettingThrough;

  /// What [read] returns while this answer lets the pop through.
  T whileLettingThrough<T>(T Function() read) {
    _isLettingThrough = true;
    try {
      return read();
    } finally {
      _isLettingThrough = false;
    }
  }
}
