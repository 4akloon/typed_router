# Observers and analytics

There are two ways to watch navigation: Flutter's `NavigatorObserver`,
for tools that take one (Sentry, analytics SDKs), and the router itself,
for typed events.

## `NavigatorObserver`s

```dart
final router = TypedRouter(
  routes: routes,
  initialRoute: const HomeRoute(),
  pageFactory: const MaterialPageFactory(),
  observers: [SentryNavigatorObserver(), analyticsObserver],
);
```

- The observers watch the root navigator and, as go_router's do, the
  navigators of shells and tabs branches too. Every event reaches them:
  push, pop, remove, replace, change of top, the start and end of a user
  gesture. For every event, the observer's `navigator` is the root one.
- Pages carry their node's `name` as `RouteSettings.name`. Name the nodes
  that analytics should see:

  ```dart
  RouteNode<RoomRoute>(
    name: 'room',
    build: (context, room) => RoomScreen(id: room.id),
  )
  ```

  A name is a label, not an address: navigation goes by route values,
  so nodes may share a name, and a node without a name is fine.
- `replace` updates the top page in place, so observers hear nothing, as
  with go_router's `replace`. `pushReplacement` is a new page and is
  heard.
- Pass a `NavigatorObserver` to one router only: Flutter attaches an
  observer to one navigator at a time, and the router manages that for
  its nested navigators.

## Typed events: listen to the router

The router is a `Listenable` and calls its listeners after every
navigation that changes `router.state`:

```dart
router.addListener(() {
  final top = router.state.top;
  analytics.logScreen(switch (top) {
    RoomRoute(:final id) => 'room/$id',
    RoomsRoute() => 'rooms',
    _ => 'other',
  });
});
```

The listener gets typed routes, sees `go`, `replace` and tab switches
alike, and does not depend on page names. Routes pushed imperatively
(`showDialog`) are not in the state; observers see those.

Prefer a `switch` on route types or the node's `name` over
`route.toString()` or `runtimeType` for anything stable: type names are
minified on the web and obfuscated in release builds.
