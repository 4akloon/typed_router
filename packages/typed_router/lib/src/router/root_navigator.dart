import 'package:flutter/widgets.dart';
import 'package:typed_router/src/redirect/router_mount.dart';

/// The root navigator of one router: the key the delegate gives it, and the
/// navigator itself while the router is shown.
class RootNavigator {
  /// Creates the root navigator of a router shown while [_mount] says so.
  RootNavigator(this._mount);

  final RouterMount _mount;

  /// The key of the root `Navigator`.
  final GlobalKey<NavigatorState> key = GlobalKey();

  /// The root navigator, or `null` while it is not mounted.
  NavigatorState? get current =>
      // Not shown: no widget tree to look in (and, in a plain test, no
      // binding for a GlobalKey to ask).
      _mount.context == null ? null : key.currentState;
}
