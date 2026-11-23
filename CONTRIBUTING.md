# Contributing to typed_router

Thanks for helping build typed_router! This guide is about developing
the project itself: setup, commands, the architecture and the conventions.
The package READMEs and `doc/` guides stay user-facing.
[CLAUDE.md](CLAUDE.md) is the short version of this file for AI coding
assistants.

## Contents

- [Prerequisites](#prerequisites)
- [Getting the code](#getting-the-code)
- [Repository layout](#repository-layout)
- [Everyday commands](#everyday-commands)
- [Architecture at a glance](#architecture-at-a-glance)
- [Coding conventions](#coding-conventions)
- [Tests](#tests)
- [Changing behaviour](#changing-behaviour)
- [Commits and pull requests](#commits-and-pull-requests)
- [Releasing](#releasing)

## Prerequisites

- **Flutter**, pinned with [FVM](https://fvm.app) in `.fvmrc`. Run every
  command through `fvm flutter` / `fvm dart`.
- The packages support **Flutter 3.44 and later**; CI also runs the tests
  on 3.44. A change that needs a newer Flutter raises the minimum in
  every `pubspec.yaml` and says so in the CHANGELOG.

## Getting the code

The repository is a pub workspace: one `pub get` at the root resolves
every member against a single lockfile.

```sh
git clone https://github.com/4akloon/typed_router.git
cd typed_router
fvm install
fvm flutter pub get
```

## Repository layout

| Path | What it is |
|---|---|
| `packages/typed_router` | The library. One entry point, `lib/typed_router.dart`; everything else in `lib/src/`. Depends on `flutter` and `meta` only. |
| `packages/typed_router/doc` | The user guides (also dartdoc categories). |
| `packages/typed_router_test` | Widget test utilities for apps: platform back. Depends on `flutter_test`, not on the core: it sends what the platform sends. |
| `example` | A catalogue of scenarios to try by hand; its page factories are the README recipes. |

`analysis_options.yaml` at the root applies to every member.

## Everyday commands

```sh
fvm flutter pub get                      # resolve the workspace
fvm dart analyze                         # analyze every member
fvm dart format .                        # format (line length 80)

(cd packages/typed_router && fvm flutter test)
(cd packages/typed_router && fvm flutter test test/operations/go_test.dart)
(cd packages/typed_router_test && fvm flutter test)
(cd example && fvm flutter test)

(cd example && fvm flutter run -d macos)  # the scenario catalogue

# Pub points, as pub.dev scores a package on its own (CI fails below 160).
fvm dart pub global activate pana
fvm dart pub global run pana packages/typed_router
```

`fvm dart analyze` and the tests of every member must be clean before a
commit.

## Architecture at a glance

`TypedRouter` is a facade: it only delegates to collaborators wired in
`router/router_parts.dart`. The folders of `lib/src/` follow them:

| Folder | Responsibility |
|---|---|
| `route/` | `TypedRoute`, the route as a value. |
| `tree/` | The declared tree (`RouteNode`, `ShellNode`, `StatefulShellNode`, `BranchNode`, `NavigatorSlot`), its validation when the router is built, and the registry that finds a route's node and parents. |
| `state/` | `TypedRouterState` and its entries: the immutable stack, shell and tabs levels, kept branch stacks. |
| `operation/` | Planning each operation (`go`, `push`, `replace`, ...) as a new state. |
| `redirect/` | Running the redirects over a target, the re-check of the stack, the error screen. |
| `transaction/` | Committing a planned state: entry lifecycles, results, notifications after the frame. |
| `result/` | The pending result of a push. |
| `page/` | Turning the state into pages for the root and nested navigators: page factories, on-screen gates for back gestures, hero controllers, observer relays. |
| `tabs/` | `StatefulShell`, branch switching and the default branch container. |
| `router/` | The facade, the `RouterDelegate`, `TypedRouter.of` and `TypedRouterState.of`, the top route's `pop`. |

A navigation runs as: operation → plan (a new `TypedRouterState`) →
redirects → transaction (commit, complete results, notify) → the delegate
rebuilds the navigators from the state.

## Coding conventions

- **No abbreviations** in any identifier; names say what a thing holds.
  Single letters only for obvious type parameters (`T` of a result).
- **Small collaborators.** A class has one responsibility; decompose a
  large class into collaborators injected through the constructor, not
  into private extensions or top-level helpers. Tell, don't ask.
- **Plain `class` by default**, as in Flutter: apps implement and fake the
  router and nodes. `sealed` for closed sets of variants,
  `abstract interface class` for seams; any other modifier names its
  reason in the dartdoc.
- **Values** are immutable with `==`, `hashCode` and a readable
  `toString`; `==` compares `runtimeType` first.
- **No `!`**: use patterns or `??`. Misuse the compiler cannot catch fails
  when the router is built, with an `ArgumentError` naming the node.
  Broken internal invariants are `StateError`. Errors of app callbacks are
  reported through `FlutterError.reportError` with
  `library: 'typed_router'`, and the navigation fails safely.
- **No `print`** or logging in `lib/`.
- **Public API:** one entry point per package with explicit `show` lists;
  dartdoc on every public member; the core imports
  `flutter/widgets.dart` only (`package_boundaries_test.dart` checks it).
  Behaviour matches `Navigator`, and go_router where `Navigator` has no
  counterpart; a deviation is allowed only where the native behaviour
  silently breaks, and is documented.
- **Files under ~150 lines.** Decompose before adding more; one public type
  per file, named after it.

## Tests

- **Test first.** A behaviour gets a failing test before the code; a bug
  fix starts with a test that reproduces it.
- **Through the public API.** Widget tests pump a real
  `WidgetsApp.router` / `MaterialApp.router` and navigate as an app does.
  Internal collaborators get unit tests only where their logic is
  non-trivial on its own.
- **Assert on state and on screen.** `router.state` and what is visible.
- **Platform behaviour is tested, not assumed:** the back button,
  predictive back, the iOS swipe, with `TargetPlatformVariant` and the
  utilities of `typed_router_test`.
- **No wall-clock waits:** `pump`, `pumpAndSettle`, completers.
- Test names are sentences about behaviour:
  `'go builds the ancestors of a nested route'`.
- Shared setup lives in `test/support/`.

## Changing behaviour

Navigation libraries break apps in subtle ways, so a change to public
behaviour starts with an issue that describes the scenario: what the app
does, what happens, what `Navigator` or go_router do in the same case.
Agree on the behaviour there, then send the pull request with tests for
each case.

## Commits and pull requests

- [Conventional commits](https://www.conventionalcommits.org):
  `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`.
- One logical change per pull request, with its tests and its CHANGELOG
  entry under `Unreleased`.
- Breaking changes are listed in the CHANGELOG with a migration note.

## Releasing

Each package is versioned and released on its own. Bump the version in
its `pubspec.yaml`, move the CHANGELOG's `Unreleased` entries under the
new version, and push a tag `<package>-v<version>`
(`typed_router-v0.8.0`); the Publish workflow publishes that package
to pub.dev.
