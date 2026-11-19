import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// What a `PageFactory` needs to create one page.
///
/// Named a request rather than a context, so it does not read like a
/// [BuildContext].
final class PageRequest {
  /// Creates a request for one stack entry. Only the router creates them.
  @internal
  const PageRequest({required this.key, required this.child});

  /// Identifies the stack entry while it lives; pass it to the page as its
  /// key, so the navigator matches the page to its route.
  final LocalKey key;

  /// The screen built by the route's node.
  final Widget child;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageRequest && other.key == key && other.child == child;

  @override
  int get hashCode => Object.hash(key, child);

  @override
  String toString() => 'PageRequest(key: $key)';
}
