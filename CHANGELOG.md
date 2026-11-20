# Changelog

## 0.3.10 - 2026-11-20

- `NavigationState.of(context)` reads the router's state and rebuilds the
  screen on every navigation, as `GoRouterState.of`.
- `NavigationState.routeAfter(route)` answers the route right above
  `route`'s entry nearest to the top: the item a list opened, which the
  list highlights while a back gesture reveals it.
- Fix: a predictive back gesture over a shell or tabs pushed above another
  page closed the whole level; it now closes the page on top inside it,
  or nothing when that page refuses with `PopScope`, as
  `NavigatorPopHandler` does. A level nested under another page no longer
  takes the gesture with it. A `maybePop` from a level's frame goes to the
  navigators inside, the deepest first.
- Fix: `resetBranch` / `resetBranchAt` rebuilt the branch's initial
  screens, so tapping the active tab again reset a tab already on its
  first page. Like go_router's `goBranch(index, initialLocation: true)`,
  the screens the initial chain shares with the branch's stack now stay,
  and nested tabs keep their stacks.

## 0.3.9 - 2026-11-19

- `StatefulShell.navigators`: the branch navigators in tab order, each
  kept alive, for a tabs builder that lays them out in its own container
  (a cross-fade, a `PageView`), like go_router's `navigatorContainerBuilder`.
  Switching stays `goBranch`; bind a scrolling container to the shell both
  ways.

## 0.3.8 - 2026-11-19

- Tabs not on screen stop ticking (`TickerMode`), and every nested
  navigator is a semantics boundary, as go_router renders them:
  `pumpAndSettle` settles with an animation in a hidden tab, and a shell's
  frame stays visible to screen readers.

## 0.3.6 - 2026-11-19

- `tester.startPredictiveBack()` in `typed_navigator/testing.dart`
  (experimental) returns a `PredictiveBackGesture` to drive the gesture
  step by step (`moveTo`, `commit`, `cancel`) and check the screen
  mid-gesture. `predictiveBack()` is built on it and now sends the touch
  position as Android does.

## 0.3.5 - 2026-11-19

- A pageless route in the navigator of a shell or a branch that leaves the
  state now completes with `null` instead of hanging forever; Flutter and
  go_router dispose such a navigator with the route.
- `StatefulShellNode` documents back on a tab root: close the app (as
  go_router), or frame the shell in a `PopScope` to go to the first tab.

## 0.3.4 - 2026-11-19

- An Android predictive back gesture now closes only the page on screen.
  With shells and tabs it used to close the top page of every navigator,
  including covered shells and hidden branches (flutter/flutter#152323,
  which go_router shares). The router's pages say they cannot pop while
  their navigator is off screen; a dialog over a shell takes the gesture
  itself. Page factories need no change.

## 0.3.3 - 2026-11-19

- Navigator slots, like go_router's `parentNavigatorKey`:
  `NavigatorSlot.root` or a `NavigatorSlot` given to a `ShellNode` or
  `BranchNode` (`navigatorSlot`), chosen by `RouteNode(parentNavigatorSlot:)`
  to show a route above the tabs or in an outer shell; its children follow
  it. Shell and tab redirects still guard such routes. A foreign slot, a
  slot deeper than the parent's navigator or a slot on two nodes fails
  when the router is built.

## 0.3.2 - 2026-11-19

- Tabs, like go_router's `StatefulShellRoute`: `StatefulShellNode` with
  `BranchNode<B>` branches named by types, each with its own navigator and
  kept stack; lazy branches; the builder frames a `StatefulShell` with
  `currentIndex`, `activeBranch`, `goBranch<B>()`, `goBranchAt`,
  `resetBranch<B>()`, `resetBranchAt`. `go` to a route of another branch
  switches to it and keeps what it can; `push` stays in the active branch.
  Malformed tabs fail when the router is built.

## 0.3.1 - 2026-11-19

- `ShellNode`, like go_router's `ShellRoute`: a frame with its own
  navigator around the routes below it; `builder(context, state,
  navigator)`, optional `pageFactory` and `redirect`. `go` keeps the shell
  while the navigation stays in it; `push` goes into the shell on screen or
  starts a new one; the back button pops the deepest current navigator
  first. `NavigationState.toString` marks shell navigators with brackets.
- A `PageFactory`'s route must show the child of its current page, as
  `MaterialPage` does: the router updates a shell's page in place.

## 0.2.2 - 2026-11-19

- `TypedRouterTargets` in `typed_navigator/testing.dart` (experimental):
  `router.stateAfterGo(route)` and `router.stateAfterPush(route)` build the
  target a redirect receives, to call a redirect on its own in a test, as
  go_router tests build a `GoRouterState`.

## 0.2.1 - 2026-11-19

- Redirects, as in go_router. `TypedRouter(redirect:)` and
  `RouteNode(redirect:)` return the route to go to instead, or `null`; they
  get the `Router`'s `BuildContext` (a dependency on an inherited widget
  re-runs them) and run while the router is shown, including before its
  first frame. A redirect replaces the operation's target (`go`, `push`,
  `replace`, `pushAndRemoveUntil`); the push of a redirected route
  completes with `null`. `refreshListenable` and `refresh()` re-check the
  whole stack. `redirectLimit` (5) and loops end in `RedirectChainError`.
  When the redirects fail as the router is shown or re-checks the stack,
  `errorBuilder` (or a plain built-in screen) is shown and
  `NavigationState.error` holds the error.

## 0.1.9 - 2026-11-19

- `typed_navigator/testing.dart` (experimental): platform back for widget
  tests. `tester.systemBack()`, `tester.predictiveBack()` and
  `tester.iosEdgeSwipe()` send what the platform sends and settle;
  `PlatformNavigationLog` records `SystemNavigator.pop` and
  `setFrameworkHandlesBack`. `flutter_test` is now a dependency for this
  entry point; the core and the adapters do not import it.

## 0.1.8 - 2026-11-19

- The Android back button goes through the router as through the native
  navigator: a dialog above the top page closes first, `PopScope` can
  block, then the top page leaves (state and its push follow); on the
  first page the platform closes the app. Routes opened imperatively
  behave natively around router operations: `push` keeps them under the
  new page, removing their page removes them.

## 0.1.7 - 2026-11-19

- Stack operations on `TypedRouter`: `go` (the route's chain from the
  tree, keeping entries of the common prefix), `push` (typed
  `Future<T?>`), `pop`, `canPop`, `popUntil`, `replace`,
  `pushAndRemoveUntil`. Every push completes exactly once: with the result
  of `pop` or of a native `Navigator.pop(context, result)`, or `null` when
  its entry leaves any other way; predicates are atomic.
- A router navigates without a widgets binding, e.g. in `main` before
  `runApp`.

## 0.1.6 - 2026-11-19

- `TypedRouter` is a `RouterConfig`: pass it to
  `MaterialApp.router(routerConfig: router)` or `WidgetsApp.router`. It
  shows the state in a root navigator, removes pages the navigator pops by
  itself (app bar back, iOS swipe, predictive back) from the state, and
  offers `navigator` for code outside the widget tree and
  `TypedRouter.of(context)`.
- `PageFactory` and `PageRequest`: the router's factory turns screens into
  pages, a `RouteNode` may have its own; a page without the request key is
  a `StateError`. `MaterialPageFactory` (`typed_navigator/material.dart`)
  and `CupertinoPageFactory` (`typed_navigator/cupertino.dart`) are ready
  to use; the core imports neither.
- **Breaking:** `TypedRouter` requires `pageFactory`. **Migration:** add
  `pageFactory: const MaterialPageFactory()` (or your own factory).

## 0.1.5 - 2026-11-19

- `TypedRouter`: the application's router, created from the route tree and
  an initial route (its ancestors built from the tree), with `state`, the
  `Listenable` contract and `dispose`; no widgets binding needed, no global
  access, several independent routers per process.

## 0.1.4 - 2026-11-19

- Navigation transaction (internal): a candidate state runs through
  synchronous steps and is committed before the call returns; listeners
  are notified only when the state changed, a failing step is reported
  and leaves the state unchanged, entries that leave the state are
  reported by identity, and navigating from a step or during build fails
  in debug.

## 0.1.3 - 2026-11-19

- `NavigationState`: an immutable, never-empty snapshot of the active path
  with `routes`, `top`, `find<R>()` and `contains<T>()`; equal when it holds
  the same pages.

## 0.1.2 - 2026-11-19

- Route tree: `RouteNode<R>` with `build`, `children` and `withParent`,
  `TreeNode<P>` and the `NoParentRoute` marker; a child's parent route is
  checked by the compiler.

## 0.1.1 - 2026-11-19

- `TypedRoute<T>`: a route as a value, with equality from `fields` and
  the result type `T`.
