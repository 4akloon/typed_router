# Migrating from go_router

typed_router keeps go_router's model: a declarative route tree,
redirects, `refreshListenable`, shells, stateful tabs, navigator keys, the
same operation names. What changes is identity: **a route is a typed
value, not a location string**. Most of a migration is replacing paths
with route classes; the structure of the tree and the screens stay.

## What you gain

- **No strings, no code generation.** A route is a class with fields.
  There is no path template to keep in sync, no `pathParameters['id']` to
  parse, no `build_runner` step as with `go_router_builder`.
- **The tree is checked by the compiler.** A child builds its parent from
  its own fields (`withParent`), so `go(MembersRoute(7))` builds
  `RoomsRoute() > RoomRoute(7) > MembersRoute(7)`, and a child under the
  wrong parent does not compile. The rest (duplicates, a missing initial
  route, a navigator slot in the wrong place) fails when the router is
  built, not on the first navigation.
- **Results are typed.** `TypedRoute<Color>` makes `push` a
  `Future<Color?>`, without a type argument to repeat at every call.
- **No `extra`.** Every parameter is a field of the route, compared by
  value; nothing is lost and nothing needs an `extra` codec.
- **Typed redirects.** A redirect reads a `TypedRouterState`
  (`target.contains<AuthArea>()`, `target.find<RoomRoute>()`) and returns
  a route. A return target is a field: `SignInRoute(returnTo: target.top)`.
- **Branches by type.** Tabs are `BranchNode<RoomsBranch>`, switched with
  `goBranch<RoomsBranch>()`; reordering tabs does not break index-based
  code.
- **Platform back in nested navigators.** The back button, the predictive
  back gesture and the iOS swipe go to the page on screen inside shells
  and tabs, with `PopScope` honoured, and there is a test package to
  prove it.
- **Design-system neutral.** The core depends on `flutter/widgets.dart`
  only; pages come from a factory the app owns.
- **No global state.** Several routers can live in one process; the
  router is an object you pass around and can fake.

## What is not there (yet)

Check these before you migrate:

- **URLs and the web.** The router neither reads nor reports URLs: no
  browser address bar, no browser history, no path-based deep links. The
  app turns incoming links into routes itself (see
  [Recipes](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/recipes.md#links-and-notifications)). If your app is a web
  app that relies on URLs, stay on go_router for now.
- **`onExit`.** Use `PopScope` for back, and confirm before the screen's
  own navigation (see
  [Back and gestures](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/back_and_gestures.md#confirming-before-leaving)).
- **State restoration** of the navigation stack.

## Concepts side by side

| go_router | typed_router |
|---|---|
| `GoRouter(routes:, initialLocation:)` | `TypedRouter(routes:, initialRoute:, pageFactory:)` |
| `GoRoute(path: 'rooms/:id', builder:)` | a `RoomRoute` class + `RouteNode<RoomRoute>(build:)` |
| nested `routes:` | `children:`, each child with `.withParent(...)` |
| `state.pathParameters['id']`, query parameters, `extra` | fields of the route: `room.id` |
| `go_router_builder`: `@TypedGoRoute`, `GoRouteData` | `TypedRoute`, no code generation |
| `GoRoute(name:)` + `goNamed` | `RouteNode(name:)`, for observers and errors only; navigation goes by values |
| `pageBuilder:` (`CustomTransitionPage`) | `pageFactory:` on the node |
| `context.go('/rooms/7')` | `TypedRouter.of(context).go(const RoomRoute(7))` |
| `context.push<T>(...)` | `push(route)`, typed by the route |
| `context.pop(result)` | `pop(result)` or `Navigator.pop(context, result)` |
| `context.replace(...)` | `replace(route)` |
| `context.pushReplacement(...)` | `pushReplacement(route)` |
| `context.canPop()` | `canPop` |
| `GoRouter.of(context)` | `TypedRouter.of(context)` |
| `GoRouterState.of(context)` | `TypedRouterState.of(context)` |
| `InheritedGoRouter` (fake router in tests) | `TypedRouterScope` |
| `redirect: (context, state) => '/sign-in'` | `redirect: (context, target) => const SignInRoute(...)` |
| `GoRoute(redirect:)` | `RouteNode(redirect: (context, route, target) => ...)` |
| `refreshListenable`, `redirectLimit` | the same |
| `errorBuilder` | `errorBuilder: (context, error) => ...` |
| `observers` | `observers`: they also hear shell and branch navigators |
| `ShellRoute(builder: (context, state, child))` | `ShellNode(builder: (context, state, navigator))` |
| `StatefulShellRoute.indexedStack` | `StatefulShellNode` |
| `StatefulShellBranch(initialLocation:)` | `BranchNode<B>(initial:)` |
| `navigationShell.goBranch(index)` | `shell.goBranchAt(index)` or `shell.goBranch<B>()` |
| `goBranch(index, initialLocation: true)` | `shell.resetBranchAt(index)` or `shell.resetBranch<B>()` |
| `StatefulShellRoute(navigatorContainerBuilder:)` | `shell.navigators` laid out in the builder |
| `parentNavigatorKey: rootNavigatorKey` | `parentNavigatorSlot: NavigatorSlot.root` |
| `navigatorKey:` on a shell or branch | `navigatorSlot: NavigatorSlot()`; `router.navigatorOf(slot)` |
| `onExit` | `PopScope`, and a check before the screen's own navigation |
| `debugLogDiagnostics` | `router.addListener(() => debugPrint('${router.state}'))` |

## Step by step

### 1. Turn each `GoRoute` into a route class

Every path parameter, query parameter and `extra` becomes a field:

```dart
// go_router: GoRoute(path: ':id', ...) under '/rooms',
// read with int.parse(state.pathParameters['id']!)
class RoomRoute extends TypedRoute<void> {
  const RoomRoute(this.id, {this.highlight});

  final int id;
  final MessageId? highlight; // was a query parameter

  @override
  List<Object?> get fields => [id, highlight];
}
```

A route that returns a value extends `TypedRoute<ThatValue>`.

If you use `go_router_builder`, the `GoRouteData` classes already are
this: keep their fields, extend `TypedRoute` instead, move `build` to the
node, and delete the `@TypedGoRoute` annotations, the generated mixins
(`with _$RoomRouteData`) and the generated part.

### 2. Rebuild the tree

The tree keeps its shape. Paths become types, and each child says how to
build its parent:

```dart
// go_router
GoRoute(
  path: '/rooms',
  builder: (context, state) => const RoomsScreen(),
  routes: [
    GoRoute(
      path: ':id',
      builder: (context, state) =>
          RoomScreen(id: int.parse(state.pathParameters['id']!)),
    ),
  ],
)

// typed_router
RouteNode<RoomsRoute>(
  build: (context, rooms) => const RoomsScreen(),
  children: [
    RouteNode<RoomRoute>(
      build: (context, room) => RoomScreen(id: room.id),
    ).withParent((room) => const RoomsRoute()),
  ],
)
```

A route that go_router reached from two places (two paths to one screen)
becomes two route types whose nodes build the same widget.

### 3. Pick a page factory

`builder:` gave you the platform's default page; here the router's
`pageFactory` does it. Copy the Material or Cupertino recipe from
[Page factories](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/page_factories.md). A `pageBuilder:` with a
`CustomTransitionPage` becomes a node's own `pageFactory`.

### 4. Replace the calls

```dart
// go_router
context.go('/rooms/7');
context.push('/rooms/7/members');
final color = await context.push<Color>('/pick-color');
context.pop(Colors.teal);

// typed_router
final router = TypedRouter.of(context);
router.go(const RoomRoute(7));
router.push(const MembersRoute(7));
final color = await router.push(const PickColorRoute());
router.pop(Colors.teal);
```

Search for `context.go`, `context.push`, `goNamed`, `pushNamed`,
`GoRouter.of` and `GoRouterState.of`; the compiler finds the rest once
go_router is removed.

### 5. Rewrite the redirects

Location checks become type checks. A marker interface replaces a list of
prefixes:

```dart
// go_router
redirect: (context, state) {
  final needsSignIn = state.matchedLocation.startsWith('/account');
  if (needsSignIn && !session.isSignedIn) {
    return '/sign-in?from=${state.matchedLocation}';
  }
  return null;
},

// typed_router
redirect: (context, target) => switch (target.top) {
  _ when target.contains<AuthArea>() && !session.isSignedIn =>
    SignInRoute(returnTo: target.top),
  SignInRoute(:final returnTo) when session.isSignedIn => returnTo,
  _ => null,
},
```

As in go_router, redirects run on `go`, `push` and the other forward
navigations, not on `pop` or platform back, and again on
`refreshListenable`. Redirects are synchronous functions: load what they
read (the session) before the router is shown.

### 6. Shells and tabs

`ShellRoute` becomes `ShellNode`; the builder gets the navigator instead
of `child`. `StatefulShellRoute.indexedStack` becomes `StatefulShellNode`
with a type per branch:

```dart
// go_router
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      HomeScaffold(shell: navigationShell),
  branches: [
    StatefulShellBranch(routes: [roomsRoute]),
    StatefulShellBranch(routes: [profileRoute]),
  ],
)

// typed_router
StatefulShellNode(
  builder: (context, state, shell) => HomeScaffold(shell: shell),
  branches: [
    BranchNode<RoomsBranch>(initial: const RoomsRoute(), children: [roomsNode]),
    BranchNode<ProfileBranch>(
      initial: const ProfileRoute(),
      children: [profileNode],
    ),
  ],
)
```

`initial` is required: go_router's default initial location (the first
route of the branch) is written out. Navigator keys become
`NavigatorSlot`s; see [Shells and tabs](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/shells_and_tabs.md).

### 7. Links

If go_router parsed your deep links, write the mapping from a link to a
route yourself and call `router.go(route)` (see
[Recipes](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/recipes.md#links-and-notifications)). The initial link becomes
`initialRoute`.

### 8. Tests

Assertions on locations become assertions on values:

```dart
// go_router
expect(router.routerDelegate.currentConfiguration.uri.path, '/rooms/7');

// typed_router
expect(router.state.routes, const [RoomsRoute(), RoomRoute(7)]);
```

Platform back, the predictive back gesture and the iOS swipe come from
`typed_router_test`; see [Testing](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/testing.md).

## Behaviour you can rely on

The operations follow `Navigator` and go_router, so screens behave the
same after the migration:

- `go` to a route of another tab switches tabs; `push` goes into the
  active tab, a route of another tab too.
- `pop` closes a dialog above the top page first, as go_router's `pop`
  does.
- `replace` updates the top page in place without a transition; observers
  hear nothing, as with go_router.
- Back on the root page of a tab closes the app, as in go_router.
- A dialog shown in the same callback as a navigation lands on the old
  page, as in go_router; see
  [Navigation](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/navigation.md#dialogs-after-a-navigation).
