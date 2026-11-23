import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router_test/src/back_gesture_channel.dart';
import 'package:typed_router_test/src/predictive_back_gesture.dart';

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
extension TypedRouterTester on WidgetTester {
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
  /// settles: [startPredictiveBack], a move to 0.35, a commit.
  ///
  /// Pages take it only with a predictive back page transition (for
  /// Material: `PredictiveBackPageTransitionsBuilder` in the theme).
  Future<void> predictiveBack() async {
    final gesture = await startPredictiveBack();
    await gesture.moveTo(0.35);
    await gesture.commit();
  }

  /// Starts an Android predictive back gesture from the left edge and pumps;
  /// drive it with the returned [PredictiveBackGesture] to check the screen
  /// mid-gesture, then commit or cancel it.
  Future<PredictiveBackGesture> startPredictiveBack() async {
    final channel = BackGestureChannel(this);
    await channel.start();
    return PredictiveBackGesture(channel);
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
}
