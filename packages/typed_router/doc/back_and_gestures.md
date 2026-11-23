# Back and gestures

Platform back works without extra code and follows the native `Navigator`:
what closes, in which order, and what `PopScope` can stop.

## The Android back button

The router's back button dispatcher sends back to `maybePop` of the
navigators on screen, the deepest shell or branch first:

1. a dialog, a bottom sheet or another route without a page closes first;
2. a local history entry (an open drawer) closes next;
3. `PopScope(canPop: false)` on the top page can refuse, and its
   `onPopInvokedWithResult` hears about it;
4. else the top page leaves, and its `push` completes with `null`;
5. on the first page, the app asks the platform to close it, as a plain
   `Navigator` app does.

`Navigator.maybePop(context)` from a screen does the same as the back
button.

## Predictive back (Android 14+)

With a predictive back page transition (for Material:
`PredictiveBackPageTransitionsBuilder` in the theme) and
`android:enableOnBackInvokedCallback="true"` in the manifest, the back
gesture shows the page below while the finger moves.

The router decides which page takes the gesture, so it works with nested
navigators:

- in a shell or a tab, only the page on screen moves, not the frame
  around it;
- a pushed shell or tabs page whose own navigator can pop closes its top
  page; one that cannot pop closes as a whole;
- a dialog over a shell page closes first;
- `PopScope(canPop: false)` on screen blocks the gesture.

## The iOS back swipe

The swipe from the left edge closes the page on screen, inside a shell or
a tab too. A page with `PopScope(canPop: false)` does not take the swipe,
as with the native `Navigator`. On the root page of a tab, when the tabs
are the app's first page, the swipe removes nothing.

## `PopScope`

`PopScope` works as with plain `Navigator` pages:

- `canPop: false` stops the back button, the predictive back gesture and
  the iOS swipe; `onPopInvokedWithResult` hears every attempt.
- Router operations (`pop`, `go`, `popUntil` and the rest) do not ask
  `PopScope`, as `Navigator.pop` does not. To ask before them too, use
  `onExit`.

## Confirming before leaving: `onExit`

A screen that must not be left silently (an unsaved draft, a lobby the
user is in) gets an `onExit` on its node, as go_router's `GoRoute.onExit`:

```dart
RouteNode<DraftRoute>(
  build: (context, draft) => const DraftScreen(),
  onExit: (context, draft, target) async =>
      drafts.isEmpty ||
      (await showDialog<bool>(
            context: context,
            builder: (context) => const DiscardDialog(),
          ) ??
          false),
)
```

`true` lets the navigation through, `false` stays. `context` is the root
navigator's, so a dialog shows above everything; `target` is the state the
navigation would show, after redirects.

**Who asks.** Every operation that removes the page from the stack on
screen: `go` (a deep link, a notification, another feature), `replace`,
`pushReplacement`, `pop`, `popUntil`, `pushAndRemoveUntil` and a tab
reset. Back asks too: the back button, predictive back,
`Navigator.maybePop` and `BackButton`. The page then does not take the
back gesture, as with `PopScope(canPop: false)`: no predictive preview, no
iOS swipe. A dialog above the page closes first, without asking. Several
pages leaving at once are asked from the top; the first `false` stops.

**Who does not ask:**

- `push` over the page and switching to another tab: the page stays.
- A re-check of the stack (`refreshListenable`, `refresh()`): a sign-out
  is not held by "Leave the draft?". go_router asks there.
- A page in a branch not on screen that a `go` replaces, as in go_router.
- `Navigator.pop(context)`, which skips `PopScope` too, and `dispose`.

**The app's only page.** Back there asks `onExit` too, as in go_router,
and the router closes the app on `true`. Such a page keeps back from the
platform, so Android 14+ shows no back-to-home preview on it.

**The page's own `PopScope`** decides first, as in go_router: with
`canPop: false` it hears the attempt and `onExit` is not asked. With
`canPop: true` it hears `didPop: false` while `onExit` is asked, then
`didPop: true` when the page leaves.

**A `Future`.** An `onExit` that returns a `bool` keeps the operation
synchronous: `router.state` changes before the call returns. One that
returns a `Future` makes the operation wait: the state stays, and `push`
or `replace` complete later (with `null` when refused). A newer navigation
while it waits wins, and the late answer is ignored. One that removes the
same page does not ask again: it takes the open question, so a second
back pops once. A re-check of the stack or a page popped outside the
router drops the waiting one. When a waiting navigation commits, the
router re-checks the stack as `refresh()` does, so a guard whose session
changed meanwhile still wins. An `onExit` that throws is reported through
`FlutterError.reportError` and counts as `false`.

## Back on the first page of a tab

Back on a tab's root page closes the app, as in go_router. To go to the
first tab first, see
[Shells and tabs](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/shells_and_tabs.md#back-on-the-first-page-of-a-tab).

## Testing back

`typed_router_test` sends what the platform sends: `tester.systemBack()`,
`tester.predictiveBack()`, `tester.startPredictiveBack()` and
`tester.iosEdgeSwipe()`. See [Testing](https://github.com/4akloon/typed_router/blob/main/packages/typed_router/doc/testing.md).
