# Example

A widget test of an app on typed_router: the Android back button and the
iOS back swipe return from a room to the list. `createRouter` is the app's
own function that builds its `TypedRouter`.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router_test/typed_router_test.dart';

import 'package:my_app/router.dart';

void main() {
  testWidgets('back returns to the rooms', (tester) async {
    final router = createRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.go(const RoomRoute(7));
    await tester.pumpAndSettle();

    await tester.systemBack();

    expect(router.state.routes, const [RoomsRoute()]);
    expect(find.text('Rooms'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('the iOS swipe returns to the rooms', (tester) async {
    final router = createRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.go(const RoomRoute(7));
    await tester.pumpAndSettle();

    await tester.iosEdgeSwipe();

    expect(router.state.routes, const [RoomsRoute()]);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
```
