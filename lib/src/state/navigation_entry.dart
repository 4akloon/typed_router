import 'package:typed_navigator/src/route/typed_route.dart';

/// One page on a stack: a route together with the identity of its page.
///
/// Entries are compared by identity, not by value. Two entries holding
/// equal routes are different pages: when the router builds a new entry
/// for an equal route, the page is built again. That is why this class
/// does not override `==`.
///
/// Internal: not exported.
final class NavigationEntry {
  /// Creates an entry for [route].
  NavigationEntry(this.route);

  /// The route shown by this page.
  final TypedRoute<Object?> route;

  @override
  String toString() => 'NavigationEntry($route)';
}
