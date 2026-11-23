# Redirects

Redirects work as in go_router: a function looks at where a navigation is
going and returns the route to go to instead, or `null` to let it
through. They are synchronous, and they receive typed values instead of
locations.

## The router's redirect

```dart
final router = TypedRouter(
  routes: routes,
  initialRoute: const HomeRoute(),
  pageFactory: const MaterialPageFactory(),
  refreshListenable: session,
  redirect: (context, target) => switch (target.top) {
    _ when target.contains<AuthArea>() && !session.isSignedIn =>
      SignInRoute(returnTo: target.top),
    SignInRoute(:final returnTo) when session.isSignedIn => returnTo,
    _ => null,
  },
);
```

- `target` is the `TypedRouterState` the navigation would show: ask it
  with `top`, `find<R>()` and `contains<T>()`.
- Marker interfaces (`AccountRoute implements AuthArea`) guard a whole
  area without listing its routes.
- A route can carry where to go next (`SignInRoute(returnTo: ...)`), as a
  typed value instead of a `?from=` query parameter.

## Node redirects

A node's `redirect` guards its subtree. It gets the node's own route for
the target, then the target:

```dart
RouteNode<AdminRoute>(
  build: (context, admin) => const AdminScreen(),
  redirect: (context, admin, target) =>
      session.isAdmin ? null : const NotAllowedRoute(),
)
```

It runs for every route of the subtree that a navigation brings in,
including a descendant pushed without the node's own route. `ShellNode`
and `StatefulShellNode` take a `redirect` too, with the target only: it
guards every route inside the shell or every branch of the tabs.

## When redirects run

- **Navigations that show a new route:** `go`, `push`, `replace`,
  `pushReplacement`, `pushAndRemoveUntil` and switching tabs. The
  redirect target goes through every redirect again.
- **Not on the way back:** `pop`, `popUntil` and platform back (the back
  button, gestures) run no redirects, as in go_router.
- **When the router is shown,** for the initial route and anything
  navigated to before `runApp`.
- **On a re-check of the whole stack:** a notification of
  `refreshListenable`, `router.refresh()`, or a change of an inherited
  widget the redirect read through its `context`. If a route on the stack
  is redirected, the stack becomes the redirect target with the routes
  above it.

Order: the router's `redirect` first, then the nodes from the top of the
tree down. The first one that returns a route wins.

## The context

Redirects get the context of the `Router` widget showing the router, so
they can read inherited widgets (`Theme`, a provider) and `TypedRouter.of`.
A redirect that depends on an inherited widget re-runs when it changes.
Do not navigate from inside a redirect: return the route instead (in
debug, navigating from a redirect fails).

## Limits and errors

- A chain of more than `redirectLimit` redirects (5 by default), or a
  loop, is a `RedirectChainError` with the whole chain.
- On an operation, a failing redirect (an exception, a chain error) is
  reported through `FlutterError.reportError` and the state stays as it
  was.
- When the router is shown or re-checks its stack, there is no previous
  screen to keep: the navigator shows `errorBuilder`'s screen (a plain one
  without it) and `router.state.error` holds the error. The next
  successful navigation clears it.

```dart
TypedRouter(
  // ...
  errorBuilder: (context, error) => ErrorScreen(error: error),
);
```

## Testing a redirect

Most redirect tests go through the app: show the router, change the
session fake, read `router.state`. To call a redirect on its own,
`router.stateAfterGo(route)` and `router.stateAfterPush(route)` build the
target a redirect would receive, without running redirects or changing
anything. See [Testing](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/testing.md).
