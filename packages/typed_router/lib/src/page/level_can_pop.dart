import 'package:flutter/foundation.dart';
import 'package:typed_router/src/page/level_inside.dart';

/// Whether a level's page lets a pop through: the level is on screen and
/// nothing inside it handles back.
///
/// The answer is read when asked, as a plain route reads its local history when
/// a back gesture starts: a drawer opened inside tells nobody (Flutter sends no
/// notification for a local history entry; `NavigatorState.canPop` counts it
/// when asked), yet the gesture must close it rather than the level. Listeners
/// hear when [refresh] finds the answer changed, so the route can tell the
/// navigator above.
class LevelCanPop extends ChangeNotifier implements ValueListenable<bool> {
  /// Creates the answer; [_inside] gives what is inside the level now.
  LevelCanPop(this._inside);

  final LevelInside Function() _inside;
  bool _isOnScreen = true;
  bool _toldValue = true;

  @override
  bool get value => _isOnScreen && !_inside().canHandlePop();

  /// Reads again with the level [isOnScreen] or not, and tells the
  /// listeners when the answer changed since they last heard.
  void refresh({required bool isOnScreen}) {
    _isOnScreen = isOnScreen;
    final now = value;
    if (now == _toldValue) return;
    _toldValue = now;
    notifyListeners();
  }
}
