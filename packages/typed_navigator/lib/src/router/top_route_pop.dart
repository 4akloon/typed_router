import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/operation/stack_operations.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';

/// `TypedRouter.pop` and `canPop` as `Navigator.pop` and go_router's: what is
/// above the state's top page closes first — a dialog or another route without
/// a page, in the page's navigator or one around it, or a drawer or bottom
/// sheet the page opened (its local history) — through its navigator; else the
/// top page leaves the state through [StackOperations], at once and with its
/// result checked.
///
/// It starts from the top page as the navigator shows it: a page pushed in
/// this frame is not shown yet, so a `pop` right after its `push` removes
/// it, as `Navigator.pop` after `Navigator.push` does.
class TopRoutePop {
  /// Creates the pop over the root navigator [_root] gives (`null` while
  /// the router is not shown), the operations and the state [_state]
  /// gives.
  TopRoutePop(this._root, this._operations, this._state);

  final NavigatorState? Function() _root;
  final StackOperations _operations;
  final NavigationState Function() _state;

  /// Whether [pop] can close something: a page of the state, or something
  /// above the top page.
  bool get canPop => _operations.canPop || _navigatorAboveTopPage() != null;

  /// Closes what is above the top page with [result]; else the top page.
  void pop(Object? result) {
    if (_navigatorAboveTopPage() case final navigator?) {
      navigator.pop(result);
      return;
    }
    _operations.pop(result);
  }

  /// The navigator whose top route stands above the state's top page: the
  /// page's own when the page closes something of its own first or a route
  /// is above it, else the first navigator around it with a route above
  /// the page that holds it. `null` when nothing is above, or the top page
  /// is not shown yet.
  NavigatorState? _navigatorAboveTopPage() {
    // Not shown: nothing is on screen (and, in a plain test, no binding
    // for a GlobalKey to ask).
    if (_root() == null || _state().error != null) return null;
    BuildContext? context = _state().entries.last.screenKey.currentContext;
    var isTopPage = true;
    while (context != null) {
      final route = ModalRoute.of(context);
      if (route == null) return null;
      final hasSomethingAbove =
          !route.isCurrent || (isTopPage && route.willHandlePopInternally);
      if (hasSomethingAbove) return route.navigator;
      context = route.navigator?.context;
      isTopPage = false;
    }
    return null;
  }
}
