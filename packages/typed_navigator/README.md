# typed_navigator

Statically typed, tree-based navigation for Flutter on Navigator 2.0.
A route is a Dart value, identified by its type and fields, never by a URL
string; routes sit in a tree declared top-down, as in go_router.

**Status:** pre-alpha. Requires Flutter 3.44 or later.

The library depends on `flutter/widgets.dart` only. Widget test utilities
(platform back, predictive back, the iOS swipe) are a separate package,
`typed_navigator_test`, for `dev_dependencies`.

## Page factories

A `PageFactory` turns every screen into a `Page`. The library ships none,
so it imports no design system; copy the one for yours.

Material (`package:material_ui`):

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

Cupertino (`package:cupertino_ui`):

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

Pass `request.key` and `request.name` to the page: the router checks the
key, and observers see the name. Give the factory `==` and `hashCode` if
the app compares factories; the example app's copies
(`example/lib/support/`) do.

```dart
final router = TypedRouter(
  routes: routes,
  initialRoute: const RoomsRoute(),
  pageFactory: const MaterialPageFactory(),
);
```

## Dialogs after a navigation

Operations change `router.state` at once; the navigator shows it in the
next frame. A dialog shown, or `Navigator.pop` called, in the same callback
as an operation reaches the old page (unlike `Navigator.push`; go_router
has the same). Take the navigator first and wait for the frame:

```dart
final navigator = Navigator.of(context);
router.push(const RoomRoute(RoomId(7)));
WidgetsBinding.instance.addPostFrameCallback(
  (_) => showDialog(context: navigator.context, builder: buildWelcome),
);
```

