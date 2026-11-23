# typed_navigator

![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.44-02569B?logo=flutter&logoColor=white)
![Status](https://img.shields.io/badge/status-experimental-orange)
![Style](https://img.shields.io/badge/style-lints-brightgreen)
![License](https://img.shields.io/badge/license-MIT-brightgreen)

**Statically typed, tree-based navigation for Flutter on Navigator 2.0 —
the go_router model, with routes that are Dart values instead of
location strings.**

- 🧭 **Routes are values.** `RoomRoute(7)` is a class with fields; equality
  comes from them. No path templates, no parsing, no code generation.
- 🌳 **A tree the compiler checks.** A child builds its parent from its
  own fields, so `go(MembersRoute(7))` builds
  `RoomsRoute() > RoomRoute(7) > MembersRoute(7)`, and a child under the
  wrong parent does not compile.
- 🎯 **Typed results.** `TypedRoute<Color>` makes `push` a
  `Future<Color?>`; `pop` and the native `Navigator.pop` complete it.
- 🛡️ **Typed redirects.** `target.contains<AuthArea>()` instead of string
  prefixes; `SignInRoute(returnTo: target.top)` instead of `?from=`.
- 🗂️ **Shells and stateful tabs** like go_router's `ShellRoute` and
  `StatefulShellRoute`, branches named by types, custom branch
  containers, navigator slots.
- 🔙 **Platform back in nested navigators.** The Android back button,
  predictive back and the iOS swipe reach the page on screen, with
  `PopScope` honoured, and a test package that sends them.
- 🧩 **Design-system neutral.** The core depends on `flutter/widgets.dart`
  only; Material and Cupertino come in through a page factory the app
  owns.

```dart
import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';

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
  pageFactory: const MaterialPageFactory(), // a recipe from the package README
);

void main() => runApp(MaterialApp.router(routerConfig: router));

// In a widget:
//   TypedRouter.of(context).push(const RoomRoute(7));
//   router.state.top == const RoomRoute(7)
```

> **Status: experimental.** The API may change before 1.0. The router does
> not read or report URLs yet, so it is not a fit for web apps that rely
> on the address bar.

---

## Table of contents

- [Why typed_navigator](#why-typed_navigator)
- [Packages](#packages)
- [Install](#install)
- [Getting started](#getting-started)
- [Documentation](#documentation)
- [Coming from go_router](#coming-from-go_router)
- [Example app](#example-app)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

## Why typed_navigator

go_router gave Flutter a good navigation model: a declarative tree,
redirects, `refreshListenable`, shells and stateful tabs. Its identity is
a location string, though, and the type safety on top of it
(`go_router_builder`) is code generation over path templates. Parameters
are parsed back from strings, and what does not fit a string goes to
`extra`.

typed_navigator keeps the model and changes the identity:

- **A route is the address.** Navigation, redirects, tests and analytics
  all see the same typed value. The parent of a route is computed from
  it, so a deep link, a notification or a redirect needs one value to
  build a whole stack.
- **Mistakes fail early.** The compiler rejects a child under the wrong
  parent and a branch in the wrong list; the router rejects duplicate
  route types, a missing initial route or a navigator slot in the wrong
  place when it is built, with the node's name in the message.
- **No surprises for `Navigator` and go_router users.** The operations
  have the same names and do the same things (`go`, `push`, `pop`,
  `replace`, `pushReplacement`, `popUntil`, `pushAndRemoveUntil`);
  `Navigator.pop`, `PopScope`, `showDialog` and observers work as they
  do with a plain `Navigator`.
- **Tested on the platform.** Back, predictive back and the iOS swipe in
  shells and tabs are covered by widget tests that send what the
  platform sends; the same utilities ship as `typed_navigator_test`.

## Packages

This repository is a pub workspace.

| Package | Role |
|---|---|
| [`typed_navigator`](packages/typed_navigator) | The router: routes, the tree, operations, redirects, shells, tabs. Depends on `flutter/widgets.dart` and `meta` only. |
| [`typed_navigator_test`](packages/typed_navigator_test) | Widget test utilities: the Android back button, the predictive back gesture, the iOS swipe, what the app told the platform. |
| [`example`](example) | A catalogue of small apps, one per way to navigate. |

## Install

```yaml
dependencies:
  typed_navigator: ^0.8.0

dev_dependencies:
  typed_navigator_test: ^0.8.0
```

Requires Flutter 3.44 or later.

## Getting started

1. Declare a `TypedRoute` subclass per screen, with the fields that
   identify it.
2. Build the tree: a `RouteNode<R>` per route type, children placed with
   `withParent`.
3. Copy the [page factory recipe](packages/typed_navigator/README.md#page-factories)
   for Material or Cupertino.
4. Create one `TypedRouter` outside the widget tree and pass it to
   `MaterialApp.router(routerConfig: router)`.
5. Navigate with `TypedRouter.of(context).go(...)`, `push`, `pop`; read
   `router.state`.

The [getting started guide](packages/typed_navigator/doc/getting_started.md)
walks through it step by step.

## Documentation

| Guide | |
|---|---|
| [Getting started](packages/typed_navigator/doc/getting_started.md) | The first app, step by step. |
| [Routes and the tree](packages/typed_navigator/doc/routes_and_tree.md) | Route values, `withParent`, checks when the router is built. |
| [Navigation](packages/typed_navigator/doc/navigation.md) | Operations, typed results, reading the state. |
| [Redirects](packages/typed_navigator/doc/redirects.md) | Guards, `refreshListenable`, errors. |
| [Shells and tabs](packages/typed_navigator/doc/shells_and_tabs.md) | `ShellNode`, `StatefulShellNode`, branch containers, navigator slots. |
| [Back and gestures](packages/typed_navigator/doc/back_and_gestures.md) | Back button, predictive back, iOS swipe, `PopScope`. |
| [Page factories](packages/typed_navigator/doc/page_factories.md) | Material, Cupertino, custom transitions. |
| [Observers and analytics](packages/typed_navigator/doc/observers.md) | `NavigatorObserver`s and typed events. |
| [Testing](packages/typed_navigator/doc/testing.md) | Widget tests, redirects, platform back, fakes. |
| [Recipes](packages/typed_navigator/doc/recipes.md) | Common tasks in a few lines each. |
| [Migrating from go_router](packages/typed_navigator/doc/migrating_from_go_router.md) | Concepts side by side and a step-by-step migration. |

The API reference is the dartdoc of every public member.

## Coming from go_router

| go_router | typed_navigator |
|---|---|
| `GoRoute(path: ':id', builder: ...)` | `RouteNode<RoomRoute>(build: ...)` + a `RoomRoute` class |
| `context.go('/rooms/7')` | `TypedRouter.of(context).go(const RoomRoute(7))` |
| `state.pathParameters['id']`, `extra` | `room.id`: fields of the route |
| `redirect` returning a location | `redirect` returning a route |
| `ShellRoute`, `StatefulShellRoute` | `ShellNode`, `StatefulShellNode` |
| `parentNavigatorKey` | `parentNavigatorSlot` |
| `GoRouterState.of(context)` | `TypedRouterState.of(context)` |

The [migration guide](packages/typed_navigator/doc/migrating_from_go_router.md)
has the full table, the steps, and what typed_navigator does not do yet
(URLs, `onExit`).

## Example app

[`example/`](example) is a catalogue of small apps: typed routes, results,
redirects, shells, tabs (with an `IndexedStack` and a `PageView`),
navigator slots, page factories, back and predictive back, observers.
Each shows the router's state live.

```sh
cd example && flutter run
```

## Roadmap

- **0.8** — documentation, recipes, migration from go_router (this
  release).
- **Next** — URLs as an optional adapter: per-route codecs for deep links
  and the web, browser history; a split view (list | detail columns on
  wide screens, one stack on phones).
- **1.0** — API review after real migrations, then a stable API.
- **Later, when a real app needs them** — state restoration, diagnostics
  for DevTools.

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md)
for the setup, the commands and the conventions.

## License

MIT. See [LICENSE](LICENSE).
