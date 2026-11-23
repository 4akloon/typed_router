# CLAUDE.md

Guidance for AI coding assistants in this repository. The human version,
with more detail, is [CONTRIBUTING.md](CONTRIBUTING.md).

## What this is

`typed_router`: a Flutter navigation library on Navigator 2.0 with
go_router's model (a declarative route tree, redirects, shells, stateful
tabs) where **a route is a typed Dart value**, identified by its type and
fields, not by a URL path.

## Layout

A pub workspace; `pubspec.yaml` at the root lists the members, and
`analysis_options.yaml` is shared.

- `packages/typed_router`: the library. One entry point
  (`lib/typed_router.dart`, explicit `show` lists), the rest in
  `lib/src/`. Depends on `flutter` and `meta` only; its tests use
  `material_ui` / `cupertino_ui` and their own page factories
  (`test/support/`). User guides in `doc/`.
- `packages/typed_router_test`: widget test utilities (platform back)
  on `flutter_test`; independent of the core.
- `example`: the scenario catalogue; its page factories are the README
  recipes.

Minimum Flutter 3.44; the repository is pinned to a newer one in `.fvmrc`.

## Commands

Always `fvm flutter` / `fvm dart`. `pub get`, `analyze` and `format` run
at the root; tests run inside a member.

```bash
fvm flutter pub get
fvm dart analyze
fvm dart format .
(cd packages/typed_router && fvm flutter test)
(cd packages/typed_router && fvm flutter test test/path/to/some_test.dart)
(cd packages/typed_router_test && fvm flutter test)
(cd example && fvm flutter test)
```

Analyze and every member's tests are clean before a commit.

## Rules

- **Behave like `Navigator`, then go_router.** A developer used to either
  must meet nothing unexpected. Deviate only where the native behaviour
  silently breaks (a lost result, an empty navigator), and document it.
- **Test first, through the public API**: widget tests pump a real
  `MaterialApp.router` and assert on `router.state` and on screen.
  Platform back is tested with `typed_router_test`
  (`tester.systemBack()`, `startPredictiveBack()`, `iosEdgeSwipe()`) and
  `TargetPlatformVariant`. No wall-clock waits.
- **Names in full**: no abbreviations, closure parameters included.
- **Small collaborators** injected through constructors; `TypedRouter`
  only delegates. Tell, don't ask. No boolean parameters that switch
  behaviour.
- **Plain `class`** by default; `sealed` for closed variant sets,
  `abstract interface class` for seams.
- **Values** are immutable with `==` (checking `runtimeType`), `hashCode`
  and `toString`.
- **No `!`**; no `print`. Misuse fails when the router is built with an
  `ArgumentError` naming the node; internal invariants are `StateError`;
  app callback errors go through `FlutterError.reportError`.
- **Design-system neutral core**: `flutter/widgets.dart` only; Material
  and Cupertino come in through `PageFactory` recipes in the README.
- **Dartdoc on every public member**; "Experimental until 1.0" instead of
  `@experimental`.
- **Files under ~150 lines**; one public type per file, named after it.
- Conventional commits; a CHANGELOG entry for every user-visible change.
