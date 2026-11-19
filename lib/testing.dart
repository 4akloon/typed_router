/// Widget test utilities for an app on typed_navigator.
///
/// Starting the app and checking where it is are plain `flutter_test`: pump
/// `MaterialApp.router(routerConfig: router)` and read `router.state`. That
/// is also how redirects are tested first: show the router, change the
/// session fake, read the state.
///
/// On top of that:
///
/// - platform back: the Android back button, the predictive back gesture
///   (whole, or step by step with [PredictiveBackGesture]) and the iOS back
///   swipe ([TypedNavigatorTester]), and what the app told the platform
///   ([PlatformNavigationLog]); a partial iOS swipe is flutter_test's own
///   `tester.startGesture`;
/// - targets for calling a redirect on its own, as go_router tests build a
///   `GoRouterState` ([TypedRouterTargets]).
///
/// Import it from tests only: it depends on `flutter_test`. Experimental
/// until 1.0: it may change without a major version.
///
/// ```dart
/// import 'package:typed_navigator/testing.dart';
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

export 'src/testing/platform_navigation_log.dart' show PlatformNavigationLog;
export 'src/testing/predictive_back_gesture.dart' show PredictiveBackGesture;
export 'src/testing/typed_navigator_tester.dart' show TypedNavigatorTester;
export 'src/testing/typed_router_targets.dart' show TypedRouterTargets;
