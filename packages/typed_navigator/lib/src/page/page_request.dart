import 'package:flutter/widgets.dart';

/// What a `PageFactory` needs to create one page.
///
/// Named a request rather than a context, so it does not read like a
/// [BuildContext].
class PageRequest {
  /// Creates a request for one stack entry.
  ///
  /// The router creates them; an app creates one to test its own
  /// `PageFactory`:
  ///
  /// ```dart
  /// final page = const FadePageFactory().createPage(
  ///   const PageRequest(key: ValueKey('rooms'), child: Text('Rooms')),
  /// );
  /// expect(page.key, const ValueKey('rooms'));
  /// ```
  const PageRequest({required this.key, required this.child, this.name});

  /// Identifies the stack entry while it lives; pass it to the page as its
  /// key, so the navigator matches the page to its route.
  final LocalKey key;

  /// The screen built by the route's node.
  final Widget child;

  /// The name of the route's node (`RouteNode.name`), or `null`; pass it to the
  /// page as its `name`, so navigator observers see it.
  final String? name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          other is PageRequest &&
          other.key == key &&
          other.child == child &&
          other.name == name;

  @override
  int get hashCode => Object.hash(key, child, name);

  @override
  String toString() => 'PageRequest(key: $key, name: $name)';
}
