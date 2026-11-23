# Shells and tabs

## `ShellNode`: a frame with its own navigator

A shell puts a frame around the routes below it and shows them in a
navigator of its own, like go_router's `ShellRoute`: a list | detail
layout, the frame of a multi-step flow.

```dart
ShellNode<NoParentRoute>(
  builder: (context, state, navigator) => ListDetailScaffold(
    list: UsersList(selected: state.find<UserRoute>()?.id),
    detail: navigator,
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

- A shell is not a route: it has no value and is not in `state.routes`.
  It is transparent for the parent type: `ShellNode<RoomsRoute>` sits
  under a `RoomsRoute` node, and its children are put there with
  `withParent` as if the shell were not there.
- `builder` gets the router's whole state and the shell's navigator, and
  rebuilds on every navigation.
- `go` builds the shell with the chain and keeps the same shell while the
  navigation stays inside it. `push` of a child goes into the shell on
  screen, or starts a new shell when another page covers it.
- Back, the back gesture and `router.pop()` close the shell's top page
  first.

## `StatefulShellNode`: tabs

Tabs keep a navigator and a stack per branch, like go_router's
`StatefulShellRoute`. Branches are named by types, never by index:

```dart
abstract class RoomsBranch {}

abstract class ProfileBranch {}

StatefulShellNode(
  builder: (context, state, shell) => Scaffold(
    body: shell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: shell.currentIndex,
      onDestinationSelected: (index) => index == shell.currentIndex
          ? shell.resetBranchAt(index)
          : shell.goBranchAt(index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.forum), label: 'Rooms'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
  ),
  branches: [
    BranchNode<RoomsBranch>(
      initial: const RoomsRoute(),
      children: [roomsNode],
    ),
    BranchNode<ProfileBranch>(
      initial: const ProfileRoute(),
      children: [profileNode],
    ),
  ],
)
```

- A branch is built on its first visit and keeps its stack while another
  one is shown.
- `go` to a route of another branch switches to that branch. `push` goes
  into the active branch, a route of another branch too, as go_router's
  `push`.
- `StatefulShell` is what the builder frames: the active branch's
  navigator, plus
  - `goBranch<B>()` / `goBranchAt(index)`: show a branch with its kept
    stack;
  - `resetBranch<B>()` / `resetBranchAt(index)`: show a branch from its
    initial route (go_router's `goBranch(index, initialLocation: true)`);
  - `currentIndex`, `activeBranch`, `branches`: for index-based widgets.
- Switching is a navigation: redirects run, listeners hear about it.
- Nodes inside a branch start their own chains (`NoParentRoute`), so a
  branch's routes fit anywhere in the tree.

### Back on the first page of a tab

As in go_router, back on the root page of any branch closes the app. To go
to the first tab instead, frame the shell in a `PopScope`:

```dart
builder: (context, state, shell) => PopScope(
  canPop: shell.currentIndex == 0,
  onPopInvokedWithResult: (didPop, result) {
    if (!didPop) shell.goBranchAt(0);
  },
  child: Scaffold(body: shell, bottomNavigationBar: ...),
),
```

### A custom branch container

To lay the branches out yourself (a cross-fade, a `PageView`), as with
go_router's `navigatorContainerBuilder`, put `shell.navigators` in your
container instead of `shell`:

```dart
builder: (context, state, shell) => PageView(
  controller: pages, // moved to shell.currentIndex when it changes
  onPageChanged: shell.goBranchAt,
  children: shell.navigators,
),
```

- The container only lays the navigators out. Switching is still
  `goBranch` / `goBranchAt`, and back goes to the branch at
  `currentIndex` whatever the container shows.
- Put each navigator in the tree exactly once, and keep the hidden ones
  in the tree, or their screens lose their state.
- Hiding is the container's job: `TickerMode`, focus, hit testing,
  semantics. `StatefulShell` itself uses an `IndexedStack` with
  `TickerMode` off for hidden branches.
- A `PageView` must also keep `onPageChanged` from switching to the
  branches an `animateToPage` passes on its way. The example app's "Tabs
  in a PageView" scenario has a complete version.

## Navigator slots

By default a route shows in the nearest shell's or branch's navigator. A
`NavigatorSlot` names a navigator, so a route can show in another one, as
go_router's `parentNavigatorKey`:

```dart
final roomsSlot = NavigatorSlot();

BranchNode<RoomsBranch>(
  navigatorSlot: roomsSlot,
  initial: const RoomsRoute(),
  children: [
    RouteNode<RoomsRoute>(
      build: (context, rooms) => const RoomsScreen(),
      children: [
        // Above the tabs, with no tab bar under it.
        RouteNode<CreateRoomRoute>(
          parentNavigatorSlot: NavigatorSlot.root,
          build: (context, create) => const CreateRoomScreen(),
        ).withParent((create) => const RoomsRoute()),
      ],
    ),
  ],
)
```

- `NavigatorSlot.root` is the router's root navigator; any other slot
  names the navigator of a `ShellNode` or `BranchNode` above the route.
- A slot is not a `GlobalKey`: every instance of a shell on the stack has
  its own navigator, and several routers can use the same tree. Slots
  compare by identity.
- Children without their own slot stay in their parent's navigator.
- `router.navigatorOf(slot)` gives the slot's navigator on screen, for
  code outside the shell that shows a dialog in it.

## Heroes and observers

- Every shell and branch navigator gets its own `HeroController` with the
  app's flight path (an arc in `MaterialApp`), as go_router does. A hero
  flies inside one navigator; heroes between navigators do not fly, as
  in Flutter.
- The router's `observers` hear the events of every shell and branch
  navigator too. See [Observers](https://github.com/4akloon/typed_navigator/blob/main/packages/typed_navigator/doc/observers.md).
