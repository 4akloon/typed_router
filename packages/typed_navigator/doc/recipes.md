# Recipes

Short answers to common navigation tasks. Each one uses only the public
API; the example app (`example/`) runs most of them.

- [Sign-in guard that returns to the target](#sign-in-guard-that-returns-to-the-target)
- [Bottom tabs that reset on reselect](#bottom-tabs-that-reset-on-reselect)
- [A page above the tabs](#a-page-above-the-tabs)
- [Ask a screen for a value](#ask-a-screen-for-a-value)
- [Links and notifications](#links-and-notifications)
- [Start deep in the tree](#start-deep-in-the-tree)
- [Navigate from outside the widget tree](#navigate-from-outside-the-widget-tree)
- [Finish a flow](#finish-a-flow)
- [Change a screen's parameters in place](#change-a-screens-parameters-in-place)
- [Highlight the item that is open](#highlight-the-item-that-is-open)
- [A list | detail layout](#a-list--detail-layout)
- [Show a dialog right after a navigation](#show-a-dialog-right-after-a-navigation)
- [Confirm before leaving a screen](#confirm-before-leaving-a-screen)
- [Toasts and overlays from a service](#toasts-and-overlays-from-a-service)
- [A full-screen dialog or a custom transition for one route](#a-full-screen-dialog-or-a-custom-transition-for-one-route)

## Sign-in guard that returns to the target

Mark the guarded routes, keep the target in the sign-in route, and let
`refreshListenable` re-check the stack when the session changes:

```dart
abstract interface class AuthArea {}

class AccountRoute extends TypedRoute<void> implements AuthArea {
  const AccountRoute();

  @override
  List<Object?> get fields => const [];
}

class SignInRoute extends TypedRoute<void> {
  const SignInRoute({required this.returnTo});

  final TypedRoute<Object?> returnTo;

  @override
  List<Object?> get fields => [returnTo];
}

final router = TypedRouter(
  routes: routes,
  initialRoute: const HomeRoute(),
  pageFactory: const MaterialPageFactory(),
  refreshListenable: session, // a ChangeNotifier
  redirect: (context, target) => switch (target.top) {
    _ when target.contains<AuthArea>() && !session.isSignedIn =>
      SignInRoute(returnTo: target.top),
    SignInRoute(:final returnTo) when session.isSignedIn => returnTo,
    _ => null,
  },
);
```

Signing in notifies the session; the re-check sends `SignInRoute` to its
`returnTo`. Signing out on a guarded screen sends the user to sign in.
More in [Redirects](https://github.com/4akloon/typed_navigator/blob/main/packages/typed_navigator/doc/redirects.md).

## Bottom tabs that reset on reselect

```dart
StatefulShellNode(
  builder: (context, state, shell) => Scaffold(
    body: shell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: shell.currentIndex,
      onDestinationSelected: (index) => index == shell.currentIndex
          ? shell.resetBranchAt(index)
          : shell.goBranchAt(index),
      destinations: destinations,
    ),
  ),
  branches: [
    BranchNode<RoomsBranch>(initial: const RoomsRoute(), children: [roomsNode]),
    BranchNode<ProfileBranch>(
      initial: const ProfileRoute(),
      children: [profileNode],
    ),
  ],
)
```

From code, switch by type: `shell.goBranch<ProfileBranch>()`, or `go` to
any route of that branch. More in [Shells and tabs](https://github.com/4akloon/typed_navigator/blob/main/packages/typed_navigator/doc/shells_and_tabs.md).

## A page above the tabs

A route inside a branch shows in the branch's navigator, under the tab
bar. To cover the tabs (a composer, a full-screen viewer), show it in the
root navigator:

```dart
RouteNode<ComposeRoute>(
  parentNavigatorSlot: NavigatorSlot.root,
  build: (context, compose) => const ComposeScreen(),
).withParent((compose) => const RoomsRoute())
```

## Ask a screen for a value

Declare the result type on the route; `push` returns it:

```dart
class PickColorRoute extends TypedRoute<Color> {
  const PickColorRoute();

  @override
  List<Object?> get fields => const [];
}

// The caller
final Color? color = await TypedRouter.of(context).push(const PickColorRoute());

// The picker
TypedRouter.of(context).pop(Colors.teal); // or Navigator.pop(context, Colors.teal)
```

Back, the swipe or any other way out completes the push with `null`.

## Links and notifications

The router takes routes, not URLs: the app turns what it receives into a
route and calls `go` (or `push`). The parsing is the app's own code, in
one place:

```dart
TypedRoute<Object?>? routeForLink(Uri link) => switch (link.pathSegments) {
  ['rooms'] => const RoomsRoute(),
  ['rooms', final id] when int.tryParse(id) != null =>
    RoomRoute(int.parse(id)),
  _ => null,
};

links.listen((link) {
  if (routeForLink(link) case final route?) router.go(route);
});

notifications.onOpened((message) => router.go(RoomRoute(message.roomId)));
```

`go` builds the routes above the target from the tree, and the redirects
check it, so a link to a guarded room still goes through sign-in.

## Start deep in the tree

`initialRoute` can be any route; the router builds the stack above it:

```dart
TypedRouter(
  routes: routes,
  initialRoute: await initialLinkRoute() ?? const RoomsRoute(),
  pageFactory: const MaterialPageFactory(),
);
```

The redirects check the initial stack when the router is first shown,
before the first frame.

## Navigate from outside the widget tree

The router is an ordinary object: pass it to whatever needs it (a view
model, a notification handler, a DI container). There is no global
instance and no `BuildContext` needed:

```dart
class CheckoutViewModel {
  CheckoutViewModel(this._router);

  final TypedRouter _router;

  Future<void> pay() async {
    await _payments.pay();
    _router.go(const OrderPlacedRoute());
  }
}
```

## Finish a flow

Close the flow's pages and land on a known route:

```dart
// Back to the rooms list, whatever the flow pushed.
router.popUntil((route) => route is RoomsRoute);

// Show the receipt with only the home page below it.
router.pushAndRemoveUntil(
  const ReceiptRoute(),
  (route) => route is HomeRoute,
);

// Start over: the receipt alone.
router.pushAndRemoveUntil(const ReceiptRoute(), (route) => false);
```

## Change a screen's parameters in place

`replace` updates the top page without a transition, and the screen keeps
its `State` (scroll position, text fields):

```dart
router.replace(SearchRoute(query: query, sort: Sort.newest));
```

For a new page with a transition, use `pushReplacement`.

## Highlight the item that is open

`TypedRouterState.of(context)` rebuilds the widget on every navigation:

```dart
@override
Widget build(BuildContext context) {
  final open = TypedRouterState.of(context).find<RoomRoute>();
  return ListView(
    children: [
      for (final room in rooms)
        RoomTile(room, isSelected: open?.id == room.id),
    ],
  );
}
```

`state.routeAfter(route)` gives the route right above another one: the
item a list opened, still known under a back gesture.

## A list | detail layout

A shell with the list in its frame and the detail in its navigator:

```dart
ShellNode<NoParentRoute>(
  builder: (context, state, navigator) => Row(
    children: [
      SizedBox(
        width: 320,
        child: UsersList(selected: state.find<UserRoute>()?.id),
      ),
      Expanded(child: navigator),
    ],
  ),
  children: [
    RouteNode<UsersRoute>(
      build: (context, users) => const NoSelection(),
      children: [
        RouteNode<UserRoute>(
          build: (context, user) => UserDetails(user.id),
        ).withParent((user) => const UsersRoute()),
      ],
    ),
  ],
)
```

## Show a dialog right after a navigation

The navigator shows a navigation in the next frame. Take the navigator
first and wait for it:

```dart
final navigator = Navigator.of(context);
router.push(const RoomRoute(7));
WidgetsBinding.instance.addPostFrameCallback(
  (_) => showDialog(context: navigator.context, builder: buildWelcome),
);
```

## Confirm before leaving a screen

There is no `onExit`: the screen that has unsaved changes asks, with a
`PopScope` for back and before its own navigation. See
[Back and gestures](https://github.com/4akloon/typed_navigator/blob/main/packages/typed_navigator/doc/back_and_gestures.md#confirming-before-leaving).

## Toasts and overlays from a service

```dart
final overlay = router.navigator?.overlay; // null while not shown
overlay?.insert(toastEntry);
```

To show a dialog inside a shell or a tab, give it a `NavigatorSlot` and
use `router.navigatorOf(slot)`.

## A full-screen dialog or a custom transition for one route

Give the node its own page factory:

```dart
RouteNode<FiltersRoute>(
  pageFactory: const MaterialPageFactory(fullscreenDialog: true),
  build: (context, filters) => const FiltersScreen(),
)
```

See [Page factories](https://github.com/4akloon/typed_navigator/blob/main/packages/typed_navigator/doc/page_factories.md) for a fade transition.
