# Testing

An app on typed_router is tested with plain `flutter_test`: pump the
app with the real router, drive it the way a user does, and assert on
`router.state` and on the screen. The companion package
`typed_router_test` adds platform back.

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  typed_router_test: ^0.8.0
```

## Navigation through the app

```dart
testWidgets('a room opens from the list', (tester) async {
  final router = createRouter(); // the app's own factory function
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));

  await tester.tap(find.text('Room 7'));
  await tester.pumpAndSettle();

  expect(router.state.routes, const [RoomsRoute(), RoomRoute(7)]);
  expect(find.text('Room 7'), findsOneWidget);
});
```

Routes are values, so the expected stack is a list literal, and a failing
test prints `[RoomsRoute(), RoomRoute(7)]`; `router.state` itself prints
as `RoomsRoute() > RoomRoute(7)`. Assert on the screen too: a
state-only assertion can hide a page that never rendered.

## Redirects

Test redirects through the app first: show the router, change the session
fake, read the state.

```dart
testWidgets('signing out leaves the account', (tester) async {
  final session = FakeSession(isSignedIn: true);
  final router = createRouter(session);
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  router.go(const AccountRoute());
  await tester.pumpAndSettle();

  session.signOut(); // notifies refreshListenable
  await tester.pumpAndSettle();

  expect(router.state.top, const SignInRoute(returnTo: AccountRoute()));
});
```

A redirect worth testing on its own gets its target from
`router.stateAfterGo(route)` or `router.stateAfterPush(route)`, the state
the navigation would build. They run no redirects and change nothing:

```dart
final target = router.stateAfterGo(const AccountRoute());
final context = tester.element(find.byType(HomeScreen));

expect(
  appRedirect(context, target),
  const SignInRoute(returnTo: AccountRoute()),
);
```

## Platform back

`typed_router_test` sends what the platform sends, then settles:

```dart
import 'package:typed_router_test/typed_router_test.dart';

testWidgets('back returns to the rooms', (tester) async {
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  router.go(const RoomRoute(7));
  await tester.pumpAndSettle();

  await tester.systemBack();

  expect(router.state.top, const RoomsRoute());
}, variant: TargetPlatformVariant.only(TargetPlatform.android));
```

| Call | Sends |
|---|---|
| `tester.systemBack()` | The Android back button (`popRoute`). |
| `tester.predictiveBack()` | A whole Android predictive back gesture: start, move, commit. |
| `tester.startPredictiveBack()` | The start of the gesture; returns a `PredictiveBackGesture` to `moveTo(progress)`, then `commit()` or `cancel()`. |
| `tester.iosEdgeSwipe()` | The iOS back swipe from the left edge. |
| `PlatformNavigationLog(tester)` | Records what the app told the platform: `closedApp`, `setFrameworkHandlesBack` values. |

Check the screen in the middle of a predictive back gesture:

```dart
final gesture = await tester.startPredictiveBack();
await gesture.moveTo(0.5);
expect(find.text('Rooms'), findsOneWidget); // the page below shows
await gesture.cancel();
expect(router.state.top, const RoomRoute(7));
```

Check that back on the first page closes the app:

```dart
final platform = PlatformNavigationLog(tester);
await tester.pumpWidget(MaterialApp.router(routerConfig: router));

await tester.systemBack();

expect(platform.closedApp, isTrue);
```

Pick the platform with `TargetPlatformVariant`: `systemBack` and the
predictive back gesture belong to Android, `iosEdgeSwipe` to iOS. A
partial iOS swipe is flutter_test's own `tester.startGesture`.

## A screen with a fake router

`TypedRouter` and `TypedRouterState` are open classes. To test a screen
alone, hand it a fake router with `TypedRouterScope`, as go_router tests
use `InheritedGoRouter`:

```dart
class FakeRouter extends Fake implements TypedRouter {
  final List<TypedRoute<Object?>> pushed = [];

  @override
  Future<T?> push<T>(TypedRoute<T> route) {
    pushed.add(route);
    return Future.value();
  }
}

testWidgets('the button opens the rooms', (tester) async {
  final router = FakeRouter();
  await tester.pumpWidget(
    MaterialApp(
      home: TypedRouterScope(router: router, child: const AccountScreen()),
    ),
  );

  await tester.tap(find.text('Rooms'));

  expect(router.pushed, const [RoomsRoute()]);
});
```

`TypedRouter.of(context)` finds the fake. `TypedRouterState.of(context)`
reads the fake's `state` once and does not rebuild when it changes.
