# Changelog

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
