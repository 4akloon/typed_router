import 'package:flutter/foundation.dart';
import 'package:typed_navigator/src/page/route_pages.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';

/// Whether a `replace` can update the top page in place: the new route stands
/// in the same levels, and the page it gets can update the page shown
/// (`Page.canUpdate`: the same kind of page and key), so the navigator updates
/// that route rather than adding one.
///
/// A page that cannot update would bring a second route, with the same
/// screen key, while the first one leaves; so the pages are built and
/// asked, not guessed from the node's factory.
class InPlaceUpdate {
  /// Creates the check over the pages [_routePages] builds.
  InPlaceUpdate(this._routePages);

  final RoutePages _routePages;

  /// [fresh] in [replaced]'s page, or `null` when it cannot take that page
  /// and needs a page of its own.
  NavigationEntry? of(NavigationEntry replaced, NavigationEntry fresh) {
    if (!listEquals(replaced.levels, fresh.levels)) return null;
    final updated = NavigationEntry.inPlaceOf(replaced, fresh);
    final canUpdate = _routePages
        .pageFor(updated)
        .canUpdate(_routePages.pageFor(replaced));
    return canUpdate ? updated : null;
  }
}
