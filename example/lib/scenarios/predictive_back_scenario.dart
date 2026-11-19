import 'package:flutter/material.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/support/demo_button.dart';
import 'package:typed_navigator_example/support/demo_page.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const predictiveBackScenario = Scenario(
  title: 'Predictive back',
  summary: 'Android 14+: the back swipe previews the page below.',
  instructions: [
    'Needs Android 14 or newer (the manifest opts in with '
        'enableOnBackInvokedCallback); Material\'s default Android '
        'transition is the predictive one. Elsewhere it is plain back.',
    'On Album or Photo, swipe slowly from the left or right edge: the page '
        'shrinks and the one below shows. Release to go back, drag back to '
        'cancel: State changes only on release.',
    'Open the dialog and swipe: the dialog takes the gesture, not the page.',
    'On Albums nothing is below: the swipe goes to the system (home).',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () => TypedRouter(
    routes: _routes,
    initialRoute: const AlbumsRoute(),
    pageFactory: const MaterialPageFactory(),
  ),
);

final List<TreeNode<NoParentRoute>> _routes = [
  RouteNode<AlbumsRoute>(
    build: (context, albums) => DemoPage(
      title: 'Albums',
      actions: [
        DemoButton(
          'open album "Summer"',
          onPressed: () =>
              TypedRouter.of(context).go(const AlbumRoute('Summer')),
        ),
      ],
    ),
    children: [
      RouteNode<AlbumRoute>(
        build: (context, album) => DemoPage(
          title: 'Album ${album.name}',
          actions: [
            DemoButton(
              'open photo 1',
              onPressed: () =>
                  TypedRouter.of(context).go(PhotoRoute(album.name, 1)),
            ),
          ],
        ),
        children: [
          RouteNode<PhotoRoute>(
            build: (context, photo) => DemoPage(
              title: 'Photo ${photo.number}',
              actions: [
                DemoButton(
                  'show a dialog',
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) =>
                        const AlertDialog(content: Text('Swipe back now.')),
                  ),
                ),
              ],
            ),
          ).withParent((photo) => AlbumRoute(photo.album)),
        ],
      ).withParent((album) => const AlbumsRoute()),
    ],
  ),
];

final class AlbumsRoute extends TypedRoute<void> {
  const AlbumsRoute();

  @override
  List<Object?> get fields => const [];
}

final class AlbumRoute extends TypedRoute<void> {
  const AlbumRoute(this.name);

  final String name;

  @override
  List<Object?> get fields => [name];
}

final class PhotoRoute extends TypedRoute<void> {
  const PhotoRoute(this.album, this.number);

  final String album;
  final int number;

  @override
  List<Object?> get fields => [album, number];
}
