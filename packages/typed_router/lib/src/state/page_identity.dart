import 'package:flutter/widgets.dart';

/// The identity of a stack entry's page: its key in the navigator and the
/// key of its screen.
///
/// A new entry gets a new one, so the navigator builds a new page. A `replace`
/// in place hands the replaced entry's identity to the new entry, so the
/// navigator updates that page and the screen keeps its state. Compared by
/// identity.
///
/// Internal: not exported.
class PageIdentity {
  /// Keys the screen of the page, so the page of a level can ask how the route
  /// on top answers a pop.
  final GlobalKey screenKey = GlobalKey();

  @override
  String toString() => 'PageIdentity(${identityHashCode(this)})';
}
