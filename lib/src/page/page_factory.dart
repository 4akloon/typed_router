import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/page_request.dart';

/// Turns a built screen into a [Page] for the navigator.
///
/// The router has one factory for every route, and a `RouteNode` may have
/// its own (a sheet, a dialog). Implement it for your design system or take
/// `MaterialPageFactory` from `package:typed_navigator/material.dart` or
/// `CupertinoPageFactory` from `package:typed_navigator/cupertino.dart`.
///
/// The page must use [PageRequest.key]; the router throws [StateError]
/// otherwise. Its route must show the child of the page it currently holds,
/// as `MaterialPage` and `CupertinoPage` do: the router updates a page in
/// place (a shell's page gets a new navigator on every navigation), and a
/// route that keeps the first child shows a stale screen. A factory does
/// not decide whether a page takes back gestures: the router does.
///
/// ```dart
/// final class FadePageFactory implements PageFactory {
///   const FadePageFactory();
///
///   @override
///   Page<Object?> createPage(PageRequest request) =>
///       FadePage(key: request.key, child: request.child);
/// }
/// ```
abstract interface class PageFactory {
  /// Creates the page that shows [request]'s screen.
  Page<Object?> createPage(PageRequest request);
}
