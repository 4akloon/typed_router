# Getting started

This guide builds a small app with two screens, a list of rooms and a
room, and walks through the four pieces every app on typed_router has:
routes, the route tree, a page factory and the router.

## Install

```yaml
dependencies:
  typed_router: ^0.9.0

dev_dependencies:
  typed_router_test: ^0.8.0 # widget test utilities, optional
```

typed_router needs Flutter 3.44 or later and depends on
`flutter/widgets.dart` only.

## 1. Routes are values

A route describes a place in the app as a Dart value. Extend
`TypedRoute<T>` once per screen and list the fields that identify it:

```dart
import 'package:typed_router/typed_router.dart';

class RoomsRoute extends TypedRoute<void> {
  const RoomsRoute();

  @override
  List<Object?> get fields => const [];
}

class RoomRoute extends TypedRoute<void> {
  const RoomRoute(this.id);

  final int id;

  @override
  List<Object?> get fields => [id];
}
```

Two routes are equal when they have the same type and equal `fields`; you
never write `==` or `hashCode` yourself. `T` is what the route returns
when it is popped: `TypedRoute<void>` returns nothing, `TypedRoute<String>`
makes `router.push(...)` a `Future<String?>`.

## 2. The route tree

The tree says where each route sits and how its screen is built. A child
node builds its parent route from its own route with `withParent`, so a
`RoomRoute(7)` always has a `RoomsRoute` below it, wherever the app
navigates from:

```dart
final routes = <TreeNode<NoParentRoute>>[
  RouteNode<RoomsRoute>(
    build: (context, rooms) => const RoomsScreen(),
    children: [
      RouteNode<RoomRoute>(
        build: (context, room) => RoomScreen(id: room.id),
      ).withParent((room) => const RoomsRoute()),
    ],
  ),
];
```

The compiler checks the shape: `withParent` must return the route type of
the node whose `children` list it is put in. What only the running app can
see (two nodes for one route type, an initial route without a node) fails
when the router is built, with a message naming the node.

## 3. A page factory

The router turns every screen into a `Page` through a `PageFactory`. The
library ships none, so it imports no design system; copy the recipe for
yours into the app (more in [Page factories](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/page_factories.md)):

```dart
import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';

class MaterialPageFactory implements PageFactory {
  const MaterialPageFactory();

  @override
  Page<Object?> createPage(PageRequest request) => MaterialPage<Object?>(
    key: request.key,
    name: request.name,
    child: request.child,
  );
}
```

`package:flutter/material.dart` works too; Flutter 3.50 deprecates it in
favour of `material_ui`.

## 4. The router

Create the router once, outside the widget tree, and hand it to
`MaterialApp.router` (or `CupertinoApp.router`, `WidgetsApp.router`):

```dart
final router = TypedRouter(
  routes: routes,
  initialRoute: const RoomsRoute(),
  pageFactory: const MaterialPageFactory(),
);

void main() => runApp(MaterialApp.router(routerConfig: router));
```

The router has no global instance: keep it where the app keeps its
dependencies (a top-level `final`, a DI container). Several independent
routers can live in one process. Whoever creates it calls
`router.dispose()`.

## 5. Navigate

From a widget, find the router with `TypedRouter.of(context)`:

```dart
TypedRouter.of(context).push(const RoomRoute(7));
```

`go` replaces the stack with a route and its ancestors from the tree;
`push` puts a route on top; `pop` closes the top route. Back buttons, the
Android back button, the predictive back gesture and the iOS swipe work
without extra code. See [Navigation](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/navigation.md).

## 6. Read the state

`router.state` is what is on screen, as an immutable value:

```dart
print(router.state); // RoomsRoute() > RoomRoute(7)
router.state.top; // RoomRoute(7)
router.state.find<RoomRoute>()?.id; // 7
```

The router is a `Listenable`: listen to it to hear about every navigation.
A widget that shows the state rebuilds with `TypedRouterState.of(context)`.

## Next

- [Routes and the tree](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/routes_and_tree.md)
- [Navigation](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/navigation.md)
- [Redirects](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/redirects.md)
- [Shells and tabs](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/shells_and_tabs.md)
- [Recipes](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/recipes.md)
- [Migrating from go_router](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/migrating_from_go_router.md)
