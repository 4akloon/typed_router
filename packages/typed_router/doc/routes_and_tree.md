# Routes and the tree

## Routes

A route is a value that names a place in the app: a type and the fields
that identify it.

```dart
class MembersRoute extends TypedRoute<void> {
  const MembersRoute(this.roomId);

  final int roomId;

  @override
  List<Object?> get fields => [roomId];
}
```

- **Equality comes from `fields`.** Two routes are equal when they have
  the same runtime type and equal `fields`, in order. Every field must
  have value equality itself: ids, enums, strings, other routes,
  immutable values. A mutable `List` compares by identity; wrap
  collections in a value type.
- **Equality decides page identity.** While an equal route stays in the
  same place on the stack, its page and the screen's `State` are kept;
  a different route gets a new page.
- **`T` is the result type.** `class PickColorRoute extends
  TypedRoute<Color>` makes `router.push(const PickColorRoute())` a
  `Future<Color?>`.
- **Routes are plain data.** How a route is shown, guarded or placed is
  declared on its node in the tree, not on the route.
- **Marker interfaces describe routes.** `class AccountRoute extends
  TypedRoute<void> implements AuthArea` lets a redirect ask
  `target.contains<AuthArea>()` instead of listing route types.
- **Routes can hold routes.** `SignInRoute(returnTo: AccountRoute())` is
  a normal value and compares by its fields.
- A class may `implement TypedRoute` instead of extending it; it then
  writes `==` and `hashCode` with value semantics itself.

`toString` prints `RoomRoute(7)`: the type and the fields. It is for
logs and test failures only. Type names are minified on the web and
obfuscated in release builds, so analytics use the node's `name`.

## The tree

The router gets a list of top-level nodes, `List<TreeNode<NoParentRoute>>`.
`NoParentRoute` marks the places where no route is above a node: the top
level, and the inside of tabs branches.

### `RouteNode`

```dart
RouteNode<RoomRoute>(
  name: 'room', // optional: page name for observers and error messages
  build: (context, room) => RoomScreen(id: room.id),
  pageFactory: null, // optional: a sheet, a dialog, a custom transition
  redirect: null, // optional: see Redirects
  parentNavigatorSlot: null, // optional: see Shells and tabs
  children: [/* nodes under RoomRoute */],
)
```

A route type has exactly one node. To show the same screen in two places,
declare two route types (`RoomRoute` and `SearchResultRoomRoute`) whose
nodes build the same widget.

### `withParent`: the parent from the child

Under a route, a node is put with `withParent`, a function that builds the
parent route from the child's route:

```dart
RouteNode<RoomRoute>(
  build: (context, room) => RoomScreen(id: room.id),
  children: [
    RouteNode<MembersRoute>(
      build: (context, members) => MembersScreen(roomId: members.roomId),
    ).withParent((members) => RoomRoute(members.roomId)),
  ],
).withParent((room) => const RoomsRoute())
```

`go(MembersRoute(7))` builds the whole stack from that one value:
`RoomsRoute() > RoomRoute(7) > MembersRoute(7)`. A deep link, a
notification or a redirect needs only the route it opens.

The types are checked by the compiler: the parent function must return
the route type of the node whose `children` the result goes into. A
`withParent` node at the top level, under the wrong parent or returning
the wrong route type does not compile. A parent function that only
throws (its type is `Never`) compiles, and fails when the router is
built.

### Nodes as classes

A feature module can declare its nodes as classes that extend the node
types and pass everything to the super constructor:

```dart
class RoomsNode extends RouteNode<RoomsRoute> {
  RoomsNode()
    : super(
        build: (context, rooms) => const RoomsScreen(),
        children: [roomNode],
      );
}
```

Overriding the nodes' members is not supported: the router relies on
them.

## Checks when the router is built

Mistakes the compiler cannot see fail in the `TypedRouter` constructor,
with an `ArgumentError` naming the node, instead of on the first
navigation:

- the route list is empty;
- a route type has two nodes;
- a node has no route type (`RouteNode(...)` without `<RoomRoute>`);
- the initial route has no node;
- a shell has no children, or tabs have no branches;
- two branches of one tabs node share a type, a branch has no type, a
  branch is empty, or its initial route is not in the branch or is shown
  outside the branch's navigator;
- a `withParent` function returns `Never`;
- one `NavigatorSlot` is given to two shells or branches;
- a `parentNavigatorSlot` is neither the root nor the slot of a shell or
  branch above the node, or names a navigator deeper than the one its
  parent route is shown in;
- `redirectLimit` is negative.

Give important nodes a `name`: error messages and observers use it, and
it survives minification.
