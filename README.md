# typed_navigator

Statically typed, tree-based navigation for Flutter on Navigator 2.0.

**Status:** pre-alpha, nothing usable yet.

## Idea

- A route is a Dart value: `RoomRoute(RoomId(7))`, identified by its type
  and fields, never by a URL string.
- Routes are placed in a tree declared top-down, like go_router: redirects,
  nested and stateful shells, `onExit`.
- The compiler checks what it can (a child that builds its parent must sit
  under that parent); the router checks the rest when it is built.
- URLs are an optional per-route codec for deep links and the web.

## Repository

A pub workspace: one `fvm flutter pub get` here resolves every package.

- [`packages/typed_navigator`](packages/typed_navigator/): the library,
  on `flutter/widgets.dart` only; page factory recipes in its README.
- [`packages/typed_navigator_test`](packages/typed_navigator_test/): widget
  test utilities, for `dev_dependencies`.
- [`example`](example/): a catalogue of scenarios to try by hand.
