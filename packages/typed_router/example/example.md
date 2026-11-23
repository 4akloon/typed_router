# Example

Two screens, a list of rooms and a room, on Material. The
[example app](https://github.com/4akloon/typed_router/tree/main/example)
in the repository has a scenario for every feature: tabs, shells, redirects,
navigator slots, typed results, back and predictive back.

```dart
import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';

class RoomsRoute extends TypedRoute<void> {
  const RoomsRoute();

  @override
  List<Object?> get fields => const [];
}

class RoomRoute extends TypedRoute<void> {
  const RoomRoute(this.id);

  final int id;

  @override
  List<Object?> get fields => [id];
}

class MaterialPageFactory implements PageFactory {
  const MaterialPageFactory();

  @override
  Page<Object?> createPage(PageRequest request) => MaterialPage<Object?>(
    key: request.key,
    name: request.name,
    child: request.child,
  );
}

final router = TypedRouter(
  routes: [
    RouteNode<RoomsRoute>(
      build: (context, rooms) => Scaffold(
        appBar: AppBar(title: const Text('Rooms')),
        body: ListView(
          children: [
            for (final id in [1, 2, 3])
              ListTile(
                title: Text('Room $id'),
                onTap: () => TypedRouter.of(context).push(RoomRoute(id)),
              ),
          ],
        ),
      ),
      children: [
        RouteNode<RoomRoute>(
          build: (context, room) => Scaffold(
            appBar: AppBar(title: Text('Room ${room.id}')),
          ),
        ).withParent((room) => const RoomsRoute()),
      ],
    ),
  ],
  initialRoute: const RoomsRoute(),
  pageFactory: const MaterialPageFactory(),
);

void main() => runApp(MaterialApp.router(routerConfig: router));
```
