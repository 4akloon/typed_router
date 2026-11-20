import 'package:flutter/material.dart';
import 'package:typed_navigator/src/page/page_factory.dart';
import 'package:typed_navigator/src/page/page_request.dart';

/// Creates a [MaterialPage] for every screen: the platform's Material
/// transitions, the iOS swipe back and Android predictive back where the
/// theme enables it.
///
/// ```dart
/// TypedRouter(
///   routes: routes,
///   initialRoute: const RoomsRoute(),
///   pageFactory: const MaterialPageFactory(),
/// );
/// ```
final class MaterialPageFactory implements PageFactory {
  /// Creates the factory; [fullscreenDialog] is passed to every page.
  const MaterialPageFactory({this.fullscreenDialog = false});

  /// [MaterialPage.fullscreenDialog] of the pages: a close button instead
  /// of back, and no swipe back on iOS. Usually set on one route's node.
  final bool fullscreenDialog;

  @override
  Page<Object?> createPage(PageRequest request) => MaterialPage<Object?>(
    key: request.key,
    name: request.name,
    fullscreenDialog: fullscreenDialog,
    child: request.child,
  );

  @override
  bool operator ==(Object other) =>
      other is MaterialPageFactory &&
      other.fullscreenDialog == fullscreenDialog;

  @override
  int get hashCode => Object.hash(MaterialPageFactory, fullscreenDialog);

  @override
  String toString() =>
      'MaterialPageFactory(fullscreenDialog: $fullscreenDialog)';
}
