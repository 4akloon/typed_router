/// Platform back for widget tests of an app on typed_navigator.
///
/// Presses the Android back button, plays the Android predictive back
/// gesture and the iOS back swipe, and records what the app tells the
/// platform about navigation. Starting the app and checking where it is are
/// plain `flutter_test`: pump `MaterialApp.router(routerConfig: router)` and
/// read `router.state`.
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
export 'src/testing/typed_navigator_tester.dart' show TypedNavigatorTester;
