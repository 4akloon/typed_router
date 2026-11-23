import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/root_observer_relay.dart';
import 'package:typed_navigator/src/state/shell_level.dart';

/// The observers of every navigator of one router: the app's on the root
/// navigator, and on each nested one a [RootObserverRelay] of its own to them
/// (Flutter attaches an observer to one navigator only). The lists stay the
/// same between builds, so a navigator does not detach and attach its observers
/// on every navigation.
class NavigatorObservers {
  /// Creates the observers around the app's [observers].
  NavigatorObservers(List<NavigatorObserver> observers)
    : root = List.unmodifiable(observers);

  /// The observers of the root navigator.
  final List<NavigatorObserver> root;

  final Expando<List<NavigatorObserver>> _nested = Expando();

  /// The observers of [level]'s navigator: a relay of its own, the same
  /// one while the level lives; none without observers on the root.
  List<NavigatorObserver> of(ShellLevel level) => root.isEmpty
      ? const []
      : _nested[level] ??= List.unmodifiable([RootObserverRelay(root)]);
}
