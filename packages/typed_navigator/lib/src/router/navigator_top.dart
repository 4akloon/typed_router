import 'package:flutter/widgets.dart';

/// The route on top of a navigator.
///
/// `NavigatorState` has no getter for it; `popUntil` hands its predicate
/// the top route first, and a predicate that holds there pops nothing.
class NavigatorTop {
  /// Creates the lookup.
  const NavigatorTop();

  /// The route on top of [navigator], or `null` when it has none.
  Route<Object?>? of(NavigatorState navigator) {
    Route<Object?>? top;
    navigator.popUntil((route) {
      top = route;
      return true;
    });
    return top;
  }

  /// Whether the route on top of [navigator] has no page: a dialog, a
  /// bottom sheet, a route pushed with `Navigator.push`.
  bool isPageless(NavigatorState navigator) =>
      switch (of(navigator)?.settings) {
        Page<Object?>() => false,
        _ => true,
      };
}
