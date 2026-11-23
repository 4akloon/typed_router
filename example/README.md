# typed_router example

A catalogue of small apps, one per way to navigate with `typed_router`.
Open an entry, follow the tips at the bottom of the screen, and watch the
router's `State:` line change.

```bash
fvm flutter run -d macos   # or any device: flutter run
```

| Scenario | Shows |
|---|---|
| Typed routes: go and push | Route values, the tree, `go` building the ancestors, `push`. |
| Typed results | `push` returning a `Future<T?>`; `router.pop` and `Navigator.pop`. |
| replace, pushReplacement, popUntil, pushAndRemoveUntil | The stack operations. |
| Initial route and deep links | Starting deep in the tree; a link as a `go` to a route. |
| Sign-in guard (redirects) | The router's redirect, a node's redirect, `refreshListenable`. |
| Redirect error screen | `errorBuilder` when the redirects fail. |
| Shell with its own navigator | `ShellNode`: a frame around a navigator. |
| Tabs (IndexedStack) | `StatefulShellNode`: kept stacks, reset on reselect, back to the first tab. |
| Tabs in a PageView | A custom branch container with `shell.navigators`. |
| Navigator slots | `parentNavigatorSlot`: a page above the tabs, a page above a shell. |
| Page factories (Material) | The router's factory, a node's own, a custom fade. |
| Cupertino app | `CupertinoApp.router` with the Cupertino factory. |
| System back | The back button, dialogs, `PopScope`. |
| Predictive back | The Android 14+ back gesture in nested navigators. |
| Exit confirmation | Confirming before leaving, without `onExit`. |
| Observers and names | `NavigatorObserver`s, node names, listening to the router. |

The bottom panel of every demo has:

- the tips: what to try and what should happen;
- `State:` — `router.state`, rebuilt on every navigation;
- **System back** — the Android back button, for desktop and the web; when
  nothing pops it says so instead of closing the app;
- **Close demo** — back to the catalogue (the demo's router is disposed).

Each demo is a whole `MaterialApp.router` (or `CupertinoApp.router`) over
its own `TypedRouter`, in one file under `lib/scenarios/`. The page
factories in `lib/support/` are the README recipes.

Predictive back needs Android 14 or newer; the manifest opts in with
`android:enableOnBackInvokedCallback="true"`.
