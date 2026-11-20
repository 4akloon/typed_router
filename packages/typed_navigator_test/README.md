# typed_navigator_test

Widget test utilities for apps on typed_navigator: the Android back button
(`tester.systemBack()`), the predictive back gesture, whole or step by step
(`tester.predictiveBack()`, `tester.startPredictiveBack()`), the iOS back
swipe (`tester.iosEdgeSwipe()`), and what the app told the platform
(`PlatformNavigationLog`).

Add it to `dev_dependencies` next to `flutter_test`:

```dart
import 'package:typed_navigator_test/typed_navigator_test.dart';

testWidgets('back returns to the rooms', (tester) async {
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  router.go(const RoomRoute(7));
  await tester.pumpAndSettle();

  await tester.systemBack();

  expect(router.state.top, const RoomsRoute());
}, variant: TargetPlatformVariant.only(TargetPlatform.android));
```

Experimental until 1.0: it may change without a major version.
