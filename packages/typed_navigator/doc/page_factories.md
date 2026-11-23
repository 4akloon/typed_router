# Page factories

A `PageFactory` turns a screen built by a node into a `Page` for the
navigator. The router has one factory for every route, and a `RouteNode`
(or a shell, or tabs) may have its own.

The library ships no factory, so the core imports no design system and
works the same with Material, Cupertino or your own. A factory is a few
lines: copy the recipe for your design system into the app.

## Material

```dart
import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';

class MaterialPageFactory implements PageFactory {
  const MaterialPageFactory({this.fullscreenDialog = false});

  final bool fullscreenDialog;

  @override
  Page<Object?> createPage(PageRequest request) => MaterialPage<Object?>(
    key: request.key,
    name: request.name,
    fullscreenDialog: fullscreenDialog,
    child: request.child,
  );
}
```

## Cupertino

```dart
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';

class CupertinoPageFactory implements PageFactory {
  const CupertinoPageFactory({this.fullscreenDialog = false});

  final bool fullscreenDialog;

  @override
  Page<Object?> createPage(PageRequest request) => CupertinoPage<Object?>(
    key: request.key,
    name: request.name,
    fullscreenDialog: fullscreenDialog,
    child: request.child,
  );
}
```

`package:flutter/material.dart` and `package:flutter/cupertino.dart` work
too; Flutter 3.50 deprecates them in favour of these packages.

## The rules of a factory

- **Pass `request.key` and `request.name` to the page.** The key ties the
  page to its stack entry; the name is the node's `name`, which observers
  see as `RouteSettings.name`. The router throws a `StateError` for a page
  without either.
- **The route shows the child of the page it holds now.** The router
  updates pages in place (`replace`, a shell's page gets a new navigator
  on every navigation). `MaterialPage` and `CupertinoPage` do this; a
  custom route must read its current page from `settings`, not keep the
  child it was created with.
- **Back gestures are the router's call.** A factory does not decide
  whether a page takes the back gesture.
- Give a factory `==` and `hashCode` if the app compares factories.

## A factory for one route

A node's `pageFactory` replaces the router's for that route: a full-screen
dialog, a custom transition.

```dart
RouteNode<FiltersRoute>(
  pageFactory: const MaterialPageFactory(fullscreenDialog: true),
  build: (context, filters) => const FiltersScreen(),
)
```

## A custom transition

A fade instead of the platform's slide. Note how the route reads its
current page from `settings`:

```dart
class FadePageFactory implements PageFactory {
  const FadePageFactory();

  @override
  Page<Object?> createPage(PageRequest request) =>
      FadePage(key: request.key, name: request.name, child: request.child);
}

class FadePage extends Page<Object?> {
  const FadePage({required this.child, super.key, super.name});

  final Widget child;

  @override
  Route<Object?> createRoute(BuildContext context) => _FadeRoute(this);
}

class _FadeRoute extends PageRoute<Object?> {
  _FadeRoute(FadePage page) : super(settings: page);

  // The page the navigator holds now: the router updates it in place.
  FadePage get _page => settings as FadePage;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => _page.child;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => FadeTransition(opacity: animation, child: child);
}
```

## Testing a factory

`PageRequest` has a public constructor for the app's own factory tests:

```dart
final page = const FadePageFactory().createPage(
  const PageRequest(key: ValueKey('rooms'), child: Text('Rooms')),
);
expect(page.key, const ValueKey('rooms'));
```
