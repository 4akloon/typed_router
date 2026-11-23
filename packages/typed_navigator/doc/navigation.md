# Navigation

Operations live on the router. From a widget:

```dart
final router = TypedRouter.of(context);
```

`TypedRouter.of` does not make the widget rebuild on navigation. Code
outside the widget tree (a view model, a notification handler) uses the
router instance it was given.

## Operations

They follow `Navigator` and go_router: a developer who knows either finds
the same names doing the same things.

| Operation | What it does |
|---|---|
| `go(route)` | Replaces the stack with `route` and the routes above it in the tree. Entries of the common prefix holding equal routes stay, with their screens' state. |
| `push(route)` | Puts `route` on top as a new entry, without its ancestors. Returns `Future<T?>` with the result it is popped with. |
| `pop([result])` | Closes the top route: a dialog or a drawer above the top page first, else the top page; its `push` completes with `result`. |
| `canPop` | Whether `pop` can close something. |
| `popUntil(predicate)` | Removes entries from the top until `predicate` holds for the top route. |
| `replace(route)` | Shows `route` in the top page, updated in place: no transition, the screen keeps its `State`. As go_router's `replace`. |
| `pushReplacement(route)` | Shows `route` in a new page in place of the top one, with a transition. As `Navigator.pushReplacement`. |
| `pushAndRemoveUntil(route, predicate)` | `popUntil`, then `push`, as one navigation. With a predicate that never holds, `route` stays alone. |
| `refresh()` | Re-runs the redirects over the whole stack. |

Every operation changes `router.state` at once and is shown in the next
frame. A navigation whose redirects fail (throw, loop) is reported through
`FlutterError.reportError` and leaves the state as it was.

### `go` or `push`?

- `go` is "show this place": the stack becomes what the tree says is
  above the route. Use it for top-level destinations, deep links, after
  sign-in.
- `push` is "open this over what I see": the current stack stays, the
  route goes on top, and the caller can await its result.

```dart
router.go(const MembersRoute(7));
// RoomsRoute() > RoomRoute(7) > MembersRoute(7)

router.go(const RoomsRoute());
router.push(const MembersRoute(7));
// RoomsRoute() > MembersRoute(7)
```

### `replace` or `pushReplacement`?

Both put a route in place of the top one, and the replaced route's push
completes with `null`.

- `replace` keeps the page: no transition, and the screen's `State`
  survives. Good for a filter or a step changing inside one screen. Give
  the screen `key: ValueKey(route)` if it should start fresh. When the
  new route stands in another navigator or its node makes another kind
  of page, it gets a new page, as with `pushReplacement`.
- `pushReplacement` shows a new page with its transition, as
  `Navigator.pushReplacement`.

Navigator observers hear nothing about `replace`, since the navigator only
updates a page (the same as go_router's `replace`). The router's own
listeners hear it.

## Typed results

A route declares its result type, and `push` returns it:

```dart
class EditNameRoute extends TypedRoute<String> {
  const EditNameRoute(this.current);

  final String current;

  @override
  List<Object?> get fields => [current];
}

final String? newName = await router.push(EditNameRoute(currentName));
```

The page completes it with `router.pop(text)` or the native
`Navigator.pop(context, text)`. Leaving any other way (the back button,
the iOS swipe, `go` elsewhere, a redirect, `router.dispose()`) completes it
with `null`. `router.pop` with a value of another type than the route's
throws an `ArgumentError`.

## Reading the state

`router.state` is a `TypedRouterState`: the routes on screen, bottom to
top, as an immutable value.

```dart
final state = router.state;
state.routes; // [RoomsRoute(), RoomRoute(7)]
state.top; // RoomRoute(7)
state.find<RoomRoute>(); // the nearest RoomRoute to the top, or null
state.contains<AuthArea>(); // any route of that type or marker interface
state.routeAfter(const RoomsRoute()); // the route right above it
```

Routes pushed imperatively over a page (`showDialog`,
`Navigator.push`) are not in the state.

To rebuild a widget on navigation, as `ModalRoute.of` or
`GoRouterState.of`:

```dart
@override
Widget build(BuildContext context) {
  final selected = TypedRouterState.of(context).find<RoomRoute>()?.id;
  return RoomList(selected: selected);
}
```

Outside the widget tree, listen to the router itself: it is a
`Listenable`.

## Dialogs after a navigation

Operations change `router.state` at once; the navigator shows it in the
next frame, as a declarative `Navigator` does. A dialog shown, or a
`Navigator.pop` called, in the same callback as an operation reaches the
old page (go_router has the same,
[flutter/flutter#146578](https://github.com/flutter/flutter/issues/146578)).
Take the navigator first and wait for the frame:

```dart
final navigator = Navigator.of(context);
router.push(const RoomRoute(7));
WidgetsBinding.instance.addPostFrameCallback(
  (_) => showDialog(context: navigator.context, builder: buildWelcome),
);
```

## Dialogs and navigators from outside the tree

- `router.navigator` is the root `NavigatorState`, or `null` while the
  router is not shown: `router.navigator?.overlay` for a toast service.
- `router.navigatorOf(slot)` is the navigator of a shell or branch with
  that [navigator slot](https://github.com/4akloon/typed_navigator/blob/main/packages/typed_navigator/doc/shells_and_tabs.md#navigator-slots), for a dialog
  inside it. Inside the shell, `Navigator.of(context)` is that navigator
  already.

## Native `Navigator` calls

The router follows the navigator:

- `Navigator.pop(context, result)` on a router page pops its entry and
  completes its push with `result`.
- `Navigator.maybePop`, `PopScope`, back buttons in app bars and the iOS
  swipe work as with plain `Navigator` pages.
- `showDialog`, `showModalBottomSheet` and `Navigator.push` of a
  `MaterialPageRoute` work as usual. They are routes without pages:
  `router.pop()` closes them first, and they are not in `router.state`.
