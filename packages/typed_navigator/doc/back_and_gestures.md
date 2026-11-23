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
  `PopScope`, as `Navigator.pop` does not. A screen that must confirm
  before its own navigation asks before calling it.

## Confirming before leaving

There is no `onExit`: the screen that owns the unsaved changes asks,
with `PopScope` for back and before its own navigation:

```dart
class _DraftScreenState extends State<DraftScreen> {
  bool _hasChanges = false;

  Future<bool> _confirmLeaving() async =>
      !_hasChanges ||
      (await showDialog<bool>(
            context: context,
            builder: (context) => const DiscardDialog(),
          ) ??
          false);

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_hasChanges,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop) return;
      final navigator = Navigator.of(context);
      if (await _confirmLeaving()) navigator.pop();
    },
    child: DraftForm(
      onChanged: () => setState(() => _hasChanges = true),
      onGoHome: () async {
        final router = TypedRouter.of(context);
        if (await _confirmLeaving()) router.go(const HomeRoute());
      },
    ),
  );
}
```

## Back on the first page of a tab

Back on a tab's root page closes the app, as in go_router. To go to the
first tab first, see
[Shells and tabs](https://github.com/4akloon/typed_navigator/blob/main/packages/typed_navigator/doc/shells_and_tabs.md#back-on-the-first-page-of-a-tab).

## Testing back

`typed_navigator_test` sends what the platform sends: `tester.systemBack()`,
`tester.predictiveBack()`, `tester.startPredictiveBack()` and
`tester.iosEdgeSwipe()`. See [Testing](https://github.com/4akloon/typed_navigator/blob/main/packages/typed_navigator/doc/testing.md).
