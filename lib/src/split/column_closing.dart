import 'package:flutter/widgets.dart';

/// How back from a split column's page closes the column and the columns to its
/// right: it asks the pages on screen to its right first, as back asks the page
/// it would close.
///
/// Identity-based: the projection makes one on every build.
final class ColumnClosing {
  /// Creates the closing that asks the pages keyed [_pagesToRight] and then
  /// runs [_close].
  ColumnClosing(this._pagesToRight, this._close);

  /// The keys of the screens on screen to the right (route columns, covers,
  /// the state's top page).
  final List<GlobalKey> _pagesToRight;
  final void Function() _close;

  /// Closes the column unless a page to its right refuses (an app's
  /// `PopScope(canPop: false)`); each refusing page hears it, as with back.
  /// [beforeClosing] runs only when the column closes. Returns whether it
  /// closed. Reads routes: call it outside a build.
  bool tryClose({required void Function() beforeClosing}) {
    final refusing = [
      for (final key in _pagesToRight)
        if (key.currentContext case final screen?)
          if (ModalRoute.popDispositionOf(screen) ==
              RoutePopDisposition.doNotPop)
            ?ModalRoute.of(screen),
    ];
    for (final route in refusing) {
      route.onPopInvokedWithResult(false, null);
    }
    if (refusing.isNotEmpty) return false;
    beforeClosing();
    _close();
    return true;
  }
}
