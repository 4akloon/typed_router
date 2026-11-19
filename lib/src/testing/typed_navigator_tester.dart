import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

/// Platform back for widget tests of an app on `TypedRouter`.
///
/// Each method sends what the platform sends, then settles the frame with
/// `pumpAndSettle`, so the test asserts on the finished navigation. The
/// platform is the test's choice (`TargetPlatformVariant`): [systemBack]
/// and [predictiveBack] belong to Android, [iosEdgeSwipe] to iOS.
///
/// ```dart
/// await tester.systemBack();
/// expect(router.state.top, const RoomsRoute());
/// ```
///
/// Experimental until 1.0: it may change without a major version.
@experimental
extension TypedNavigatorTester on WidgetTester {
  /// Presses the Android back button: sends `popRoute` as the platform
  /// does, then settles.
  ///
  /// The app's back button dispatcher decides what closes, as on a device:
  /// a dialog above the top page first, `PopScope` may refuse, and on the
  /// first page the app asks the platform to close it (see
  /// [PlatformNavigationLog.closedApp]).
  Future<void> systemBack() async {
    await binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.navigation.name,
      SystemChannels.navigation.codec.encodeMethodCall(
        const MethodCall('popRoute'),
      ),
      (_) {},
    );
    await pumpAndSettle();
  }

  /// Starts, drags and commits an Android predictive back gesture, then
  /// settles.
  ///
  /// Pages take it only with a predictive back page transition (for
  /// Material: `PredictiveBackPageTransitionsBuilder` in the theme). The
  /// gesture always completes; a cancelled or partial gesture is not
  /// offered.
  Future<void> predictiveBack() async {
    await _sendBackGesture('startBackGesture', {
      'touchOffset': <double>[5, 300],
      'progress': 0.0,
      'swipeEdge': 0,
    });
    await pump();
    await _sendBackGesture('updateBackGestureProgress', {
      'x': 100.0,
      'y': 300.0,
      'progress': 0.35,
      'swipeEdge': 0,
    });
    await pump();
    await _sendBackGesture('commitBackGesture');
    await pumpAndSettle();
  }

  /// Swipes from the left edge across the screen, as the iOS back swipe,
  /// then settles.
  ///
  /// Pages take it with a Cupertino page transition, which Material pages
  /// use on iOS too.
  Future<void> iosEdgeSwipe() async {
    await dragFrom(const Offset(5, 300), const Offset(500, 0));
    await pumpAndSettle();
  }

  Future<void> _sendBackGesture(
    String method, [
    Map<String, Object?>? arguments,
  ]) => binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/backgesture',
    const StandardMethodCodec().encodeMethodCall(MethodCall(method, arguments)),
    (_) {},
  );
}
