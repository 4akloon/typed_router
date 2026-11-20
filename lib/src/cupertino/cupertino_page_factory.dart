import 'package:flutter/cupertino.dart';
import 'package:typed_navigator/src/page/page_factory.dart';
import 'package:typed_navigator/src/page/page_request.dart';

/// Creates a [CupertinoPage] for every screen: iOS transitions and the swipe
/// back from the edge.
///
/// ```dart
/// TypedRouter(
///   routes: routes,
///   initialRoute: const RoomsRoute(),
///   pageFactory: const CupertinoPageFactory(),
/// );
/// ```
final class CupertinoPageFactory implements PageFactory {
  /// Creates the factory; [fullscreenDialog] is passed to every page.
  const CupertinoPageFactory({this.fullscreenDialog = false});

  /// [CupertinoPage.fullscreenDialog] of the pages: slides up from the
  /// bottom, no swipe back. Usually set on one route's node.
  final bool fullscreenDialog;

  @override
  Page<Object?> createPage(PageRequest request) => CupertinoPage<Object?>(
    key: request.key,
    name: request.name,
    fullscreenDialog: fullscreenDialog,
    child: request.child,
  );

  @override
  bool operator ==(Object other) =>
      other is CupertinoPageFactory &&
      other.fullscreenDialog == fullscreenDialog;

  @override
  int get hashCode => Object.hash(CupertinoPageFactory, fullscreenDialog);

  @override
  String toString() =>
      'CupertinoPageFactory(fullscreenDialog: $fullscreenDialog)';
}
