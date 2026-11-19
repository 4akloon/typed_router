import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:typed_navigator/src/route/typed_route.dart';

/// One column a `SplitNode` shows, for a builder that lays the columns out
/// itself: [SplitView.columns].
///
/// Compared by identity: [child] is a widget made for one build.
sealed class SplitColumn {
  const SplitColumn._(this.route, this.child);

  /// The route the column belongs to: its own for a [RouteColumn], the top
  /// route whose placeholder it is for a [PlaceholderColumn].
  final TypedRoute<Object?> route;

  /// What to put in the column. Put it in the tree exactly once.
  final Widget child;
}

/// A column showing [route] in a navigator of its own; while the split
/// shows a stack, its only column, holding the whole stack with [route] on
/// top.
final class RouteColumn extends SplitColumn {
  /// Created by the router.
  @internal
  const RouteColumn(super.route, super.child) : super._();

  @override
  String toString() => 'RouteColumn($route)';
}

/// The placeholder of [route], the top route, in the column after it
/// (`RouteNode.placeholder`).
final class PlaceholderColumn extends SplitColumn {
  /// Created by the router.
  @internal
  const PlaceholderColumn(super.route, super.child) : super._();

  @override
  String toString() => 'PlaceholderColumn($route)';
}
