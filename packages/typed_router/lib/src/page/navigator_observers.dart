import 'package:flutter/widgets.dart';
import 'package:typed_router/src/page/root_observer_relay.dart';

/// The observers of every navigator of one router: the app's on the root
/// navigator, and on each nested one a [RootObserverRelay] of its own to them
/// (Flutter attaches an observer to one navigator only). A new relay on every
/// build is harmless: a navigator detaches its old observers before it attaches
/// the new ones, as go_router's merged observer is made anew on every build.
class NavigatorObservers {
  /// Creates the observers around the app's [observers].
  NavigatorObservers(List<NavigatorObserver> observers)
    : root = List.unmodifiable(observers);

  /// The observers of the root navigator.
  final List<NavigatorObserver> root;

  /// The observers of a nested navigator: a relay of its own to the
  /// root's; none without observers on the root.
  List<NavigatorObserver> nested() =>
      root.isEmpty ? const [] : [RootObserverRelay(root)];
}
