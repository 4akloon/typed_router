import 'package:flutter/widgets.dart';
import 'package:typed_navigator/typed_navigator.dart';

/// The platform's back button, sent from a button of the demo so it can be
/// tried on desktop and the web, where there is none.
///
/// It takes the path of Android's back button: the router's
/// [RootBackButtonDispatcher] asks the current navigators to `maybePop`, so
/// a dialog closes first and `PopScope` can refuse. When nothing pops,
/// Android would close the app; the demo reports it instead of quitting.
final class SystemBack {
  const SystemBack(this.router);

  final TypedRouter router;

  /// Sends back; returns what to tell the user when nothing handled it.
  Future<String?> send() async {
    if (router.backButtonDispatcher case final RootBackButtonDispatcher root) {
      final isHandled = await root.didPopRoute();
      return isHandled ? null : 'Nothing popped: Android would close the app.';
    }
    return 'The router has no root back button dispatcher.';
  }

  @override
  String toString() => 'SystemBack($router)';
}
