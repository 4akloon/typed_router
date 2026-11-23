# typed_navigator_test

![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.44-02569B?logo=flutter&logoColor=white)
![Part of](https://img.shields.io/badge/part_of-typed__navigator-informational)
![Status](https://img.shields.io/badge/status-experimental-orange)
![License](https://img.shields.io/badge/license-MIT-brightgreen)

**Widget test utilities for apps on [typed_navigator](https://github.com/4akloon/typed_navigator/tree/main/packages/typed_navigator):
platform back, sent the way the platform sends it.**

Starting the app and checking where it is are plain `flutter_test`: pump
`MaterialApp.router(routerConfig: router)` and read `router.state`. This
package adds what `flutter_test` has no helper for:

- the Android back button: `tester.systemBack()`;
- the predictive back gesture, whole or step by step:
  `tester.predictiveBack()`, `tester.startPredictiveBack()`;
- the iOS back swipe: `tester.iosEdgeSwipe()`;
- what the app told the platform (closing the app,
  `setFrameworkHandlesBack`): `PlatformNavigationLog`.

## Install

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  typed_navigator_test: ^0.8.0
```

Import it from tests only: it depends on `flutter_test`. It does not depend
on `typed_navigator` itself: it sends what the platform sends, and the
router answers as it would on a device.

## Usage

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

Every call sends what the platform sends, then settles with
`pumpAndSettle`, so the test asserts on the finished navigation. Pick the
platform with `TargetPlatformVariant`: `systemBack` and predictive back
belong to Android, `iosEdgeSwipe` to iOS.

### The predictive back gesture, step by step

```dart
final gesture = await tester.startPredictiveBack();
await gesture.moveTo(0.5);
expect(find.text('Rooms'), findsOneWidget); // the page below shows
await gesture.cancel(); // or commit()
```

Pages take the gesture only with a predictive back page transition (for
Material: `PredictiveBackPageTransitionsBuilder` in the theme). A gesture
no page takes moves nothing; `commit()` then falls back to the back
button.

### Closing the app

```dart
final platform = PlatformNavigationLog(tester);
await tester.pumpWidget(MaterialApp.router(routerConfig: router));

await tester.systemBack();

expect(platform.closedApp, isTrue);
```

## API

| Member | What it does |
|---|---|
| `tester.systemBack()` | Sends `popRoute`, as the Android back button does. |
| `tester.predictiveBack()` | Starts, moves to 0.35 and commits a predictive back gesture from the left edge. |
| `tester.startPredictiveBack()` | Starts a predictive back gesture and returns it. |
| `PredictiveBackGesture` | `moveTo(progress)`, `commit()`, `cancel()`. |
| `tester.iosEdgeSwipe()` | Swipes from the left edge across the screen. |
| `PlatformNavigationLog` | `closedApp`; `frameworkHandlesBack`, every `setFrameworkHandlesBack` value. |

More in the [testing guide](https://github.com/4akloon/typed_navigator/blob/main/packages/typed_navigator/doc/testing.md).

Experimental until 1.0: the API may change without a major version.

## License

MIT. See [LICENSE](https://github.com/4akloon/typed_navigator/blob/main/packages/typed_navigator_test/LICENSE).
