import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:typed_navigator/src/page/level_inside.dart';

/// The pop entry of a level's page (a shell's or a tabs instance's), as
/// Flutter's `NavigatorPopHandler`: the page lets a pop through only while it
/// is on screen and nothing inside it handles back.
///
/// So a back gesture over a level goes to the page inside, not to the level's
/// page as well (flutter/flutter#152323); a level off screen does not take it
/// at all, as the router's pages. A `maybePop` the entry turns away goes
/// inside, where the system back button goes too.
class LevelPopEntry extends PopEntry<Object?> {
  /// Creates the entry; [_inside] gives what is inside the level now.
  LevelPopEntry(this._inside);

  final LevelInside Function() _inside;
  final ValueNotifier<bool> _canPop = ValueNotifier(true);

  @override
  ValueListenable<bool> get canPopNotifier => _canPop;

  /// Reads again what is inside, with the level [isOnScreen] or not, as
  /// the navigators inside hold it now.
  void refresh({required bool isOnScreen}) =>
      _canPop.value = isOnScreen && !_inside().canHandlePop();

  @override
  void onPopInvokedWithResult(bool didPop, Object? result) {
    // Off screen, nothing inside is current, so this gives back to no one.
    // Unawaited, not ignored: an error of an app's PopScope inside reaches the
    // zone, as through system back.
    if (!didPop) unawaited(_inside().maybePop());
  }

  /// Releases the listeners of the route.
  void dispose() => _canPop.dispose();
}
