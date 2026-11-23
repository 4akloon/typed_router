# typed_router

![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.44-02569B?logo=flutter&logoColor=white)
![Dependencies](https://img.shields.io/badge/depends_on-flutter%2Fwidgets-informational)
![Status](https://img.shields.io/badge/status-experimental-orange)
![License](https://img.shields.io/badge/license-MIT-brightgreen)

**Statically typed, tree-based navigation for Flutter on Navigator 2.0.**
A route is a Dart value, identified by its type and fields, never by a
URL string. Routes sit in a tree declared top-down, as in go_router, with
redirects, shells and stateful tabs.

```dart
class RoomRoute extends TypedRoute<void> {
  const RoomRoute(this.id);

  final int id;

  @override
  List<Object?> get fields => [id];
}

final router = TypedRouter(
  routes: [
    RouteNode<RoomsRoute>(
      build: (context, rooms) => const RoomsScreen(),
      children: [
        RouteNode<RoomRoute>(
          build: (context, room) => RoomScreen(id: room.id),
        ).withParent((room) => const RoomsRoute()),
      ],
    ),
  ],
  initialRoute: const RoomsRoute(),
  pageFactory: const MaterialPageFactory(),
);

// Anywhere below MaterialApp.router(routerConfig: router):
TypedRouter.of(context).go(const RoomRoute(7)); // RoomsRoute() > RoomRoute(7)
```

- **Routes are values.** Equality comes from the fields; no paths, no
  parsing, no code generation.
- **The compiler checks the tree.** A child builds its parent from its own
  fields, so `go` to any route builds the whole stack, and a child under
  the wrong parent does not compile.
- **Typed results.** `TypedRoute<Color>` makes `push` a `Future<Color?>`.
- **Typed redirects.** Ask the target `contains<AuthArea>()` and return a
  route, such as `SignInRoute(returnTo: target.top)`.
- **Shells and tabs** like go_router's `ShellRoute` and
  `StatefulShellRoute`, with branches named by types.
- **Platform back in nested navigators:** the back button, predictive
  back and the iOS swipe reach the page on screen, with `PopScope`.
- **Ask before leaving:** `onExit` on a node, as go_router's, asked by
  every operation that removes the page and by back.
- **Behaves like `Navigator` and go_router**: the same operations
  (`go`, `push`, `pop`, `replace`, `pushReplacement`, `popUntil`,
  `pushAndRemoveUntil`) doing the same things.
- **Design-system neutral:** depends on `flutter/widgets.dart` only.

> **Status: experimental.** The API may change before 1.0. The router does
> not read or report URLs yet: the app turns its links into routes.

## Contents

- [Install](#install)
- [Quick start](#quick-start)
- [Page factories](#page-factories)
- [Guides](#guides)
- [Limitations](#limitations)
- [License](#license)

## Install

```yaml
dependencies:
  typed_router: ^0.8.0

dev_dependencies:
  typed_router_test: ^0.8.0 # platform back in widget tests, optional
```

Requires Flutter 3.44 or later.

## Quick start

1. **Declare routes**: one `TypedRoute` subclass per screen, with the
   fields that identify it. `T` is the type the route returns when
   popped.
2. **Build the tree**: a `RouteNode<R>` per route type; put children under
   a route with `withParent`.
3. **Copy a page factory** for your design system (below).
4. **Create the router** once, outside the widget tree, and pass it to
   `MaterialApp.router(routerConfig: router)`.
5. **Navigate** with `TypedRouter.of(context)`: `go`, `push`, `pop`.
6. **Read** `router.state`, an immutable `TypedRouterState`, or rebuild a
   widget with `TypedRouterState.of(context)`.

The [getting started guide](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/getting_started.md) walks through it.

## Page factories

A `PageFactory` turns every screen into a `Page`. The library ships none,
so it imports no design system; copy the one for yours.

Material (`package:material_ui`):

```dart
import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';

class MaterialPageFactory implements PageFactory {
  const MaterialPageFactory({this.fullscreenDialog = false});

  final bool fullscreenDialog;

  @override
  Page<Object?> createPage(PageRequest request) => MaterialPage<Object?>(
    key: request.key,
    name: request.name,
    fullscreenDialog: fullscreenDialog,
    child: request.child,
  );
}
```

Cupertino (`package:cupertino_ui`):

```dart
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:typed_router/typed_router.dart';

class CupertinoPageFactory implements PageFactory {
  const CupertinoPageFactory({this.fullscreenDialog = false});

  final bool fullscreenDialog;

  @override
  Page<Object?> createPage(PageRequest request) => CupertinoPage<Object?>(
    key: request.key,
    name: request.name,
    fullscreenDialog: fullscreenDialog,
    child: request.child,
  );
}
```

`package:flutter/material.dart` and `package:flutter/cupertino.dart` work
too; Flutter 3.50 deprecates them in favour of these packages.

Pass `request.key` and `request.name` to the page: the router checks the
key, and observers see the name. A custom transition: see
[Page factories](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/page_factories.md).

## Guides

| Guide | What it covers |
|---|---|
| [Getting started](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/getting_started.md) | Routes, the tree, a page factory, the router, the first navigation. |
| [Routes and the tree](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/routes_and_tree.md) | Route equality, `withParent`, nodes as classes, checks when the router is built. |
| [Navigation](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/navigation.md) | `go`, `push`, `pop`, `replace`, `pushReplacement`, `popUntil`, `pushAndRemoveUntil`, typed results, reading the state. |
| [Redirects](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/redirects.md) | The router's and the nodes' redirects, `refreshListenable`, errors. |
| [Shells and tabs](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/shells_and_tabs.md) | `ShellNode`, `StatefulShellNode`, custom branch containers, navigator slots. |
| [Back and gestures](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/back_and_gestures.md) | The back button, predictive back, the iOS swipe, `PopScope`, `onExit`. |
| [Page factories](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/page_factories.md) | Material, Cupertino, a custom transition, a factory per route. |
| [Observers and analytics](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/observers.md) | `NavigatorObserver`s, node names, typed events. |
| [Testing](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/testing.md) | Tests through the app, redirects, platform back, a fake router. |
| [Recipes](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/recipes.md) | Sign-in guards, tabs, links, flows, dialogs after navigation and more. |
| [Migrating from go_router](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/migrating_from_go_router.md) | Concepts side by side, step by step, and what you gain. |

## Limitations

- No URLs yet: no web address bar, browser history or path-based deep
  links. The app maps its links to routes and calls `go`.
- No state restoration of the navigation stack.

## License

MIT. See [LICENSE](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/LICENSE).
