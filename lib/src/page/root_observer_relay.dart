import 'package:flutter/widgets.dart';

/// Hands the events of one nested navigator (a shell's, a branch's) to the
/// observers of the root navigator, as go_router's merged observer does:
/// Flutter attaches an observer to one navigator only, so each nested navigator
/// gets a relay of its own.
final class RootObserverRelay extends NavigatorObserver {
  /// Creates the relay to [_rootObservers].
  RootObserverRelay(this._rootObservers);

  final List<NavigatorObserver> _rootObservers;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in _rootObservers) {
      observer.didPush(route, previousRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in _rootObservers) {
      observer.didPop(route, previousRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final observer in _rootObservers) {
      observer.didRemove(route, previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    for (final observer in _rootObservers) {
      observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    }
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    for (final observer in _rootObservers) {
      observer.didChangeTop(topRoute, previousTopRoute);
    }
  }

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    for (final observer in _rootObservers) {
      observer.didStartUserGesture(route, previousRoute);
    }
  }

  @override
  void didStopUserGesture() {
    for (final observer in _rootObservers) {
      observer.didStopUserGesture();
    }
  }
}
