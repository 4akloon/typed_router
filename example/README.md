# typed_navigator example

A catalogue of small apps, one per way to navigate with `typed_navigator`.
Open an entry, follow the tips at the bottom of the screen, and watch the
router's `State:` line change.

```bash
fvm flutter run -d macos
```

The bottom panel of every demo has:

- the tips: what to try and what should happen;
- `State:` — `router.state`, rebuilt on every navigation;
- **System back** — the Android back button, for desktop and the web; when
  nothing pops it says so instead of closing the app;
- **Close demo** — back to the catalogue (the demo's router is disposed).

Each demo is a whole `MaterialApp.router` (or `CupertinoApp.router`) over its
own `TypedRouter`, in one file under `lib/scenarios/`.

Predictive back needs Android 14 or newer; the manifest opts in with
`android:enableOnBackInvokedCallback="true"`.
