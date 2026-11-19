import 'package:flutter/widgets.dart';

/// The key of the empty page under the deepest column of a split, so the
/// column's route can pop like any page above another.
final class BlankPageKey extends LocalKey {
  /// The one key: a navigator has at most one such page.
  const BlankPageKey();

  @override
  bool operator ==(Object other) => other is BlankPageKey;

  @override
  int get hashCode => (BlankPageKey).hashCode;

  @override
  String toString() => 'BlankPageKey()';
}
