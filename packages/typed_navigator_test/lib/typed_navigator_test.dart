/// Widget test utilities for an app on typed_navigator.
///
/// Starting the app and checking where it is are plain `flutter_test`: pump
/// `MaterialApp.router(routerConfig: router)` and read `router.state`. That
/// is also how redirects are tested first: show the router, change the
/// session fake, read the state. A redirect worth testing on its own gets
/// its target from `router.stateAfterGo` / `router.stateAfterPush`.
///
/// On top of that, platform back: the Android back button, the predictive
/// back gesture (whole, or step by step with [PredictiveBackGesture]) and
/// the iOS back swipe ([TypedNavigatorTester]), and what the app told the
/// platform ([PlatformNavigationLog]); a partial iOS swipe is
/// flutter_test's own `tester.startGesture`.
///
/// Add the package to `dev_dependencies` and import it from tests only: it
/// depends on `flutter_test`. Experimental until 1.0: it may change without
/// a major version.
///
/// ```dart
/// import 'package:typed_navigator_test/typed_navigator_test.dart';
///
/// testWidgets('back returns to the rooms', (tester) async {
///   await tester.pumpWidget(MaterialApp.router(routerConfig: router));
///   router.go(const RoomRoute(7));
///   await tester.pumpAndSettle();
///
///   await tester.systemBack();
///
///   expect(router.state.top, const RoomsRoute());
/// }, variant: TargetPlatformVariant.only(TargetPlatform.android));
/// ```
library;

export 'src/platform_navigation_log.dart' show PlatformNavigationLog;
export 'src/predictive_back_gesture.dart' show PredictiveBackGesture;
export 'src/typed_navigator_tester.dart' show TypedNavigatorTester;
