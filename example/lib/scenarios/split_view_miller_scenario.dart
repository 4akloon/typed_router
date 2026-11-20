import 'package:flutter/material.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/support/router_demo.dart';
import 'package:typed_navigator_example/support/tap_counter.dart';

const splitViewMillerScenario = Scenario(
  title: 'Miller columns',
  summary: 'SplitNode with as many columns as fit: the last levels shown.',
  instructions: [
    'One column per 260 of width (a stack below 520). Open folders: each '
        'opens in the next column; when they do not fit, the first ones go '
        'offstage, alive.',
    'Tap a folder in an earlier column: the deeper columns close and the '
        'new one opens (popUntil, then push).',
    'The back button of any column but the first closes it and the '
        'columns to its right. Android back and the back gestures close the '
        'deepest column only.',
    'Resize the window: the number of columns follows, the counters stay.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () => TypedRouter(
    routes: _routes,
    initialRoute: const FolderRoute('Home'),
    pageFactory: const MaterialPageFactory(),
  ),
);

final List<TreeNode<NoParentRoute>> _routes = [
  SplitNode<NoParentRoute>(
    maximumColumns: (size) => (size.width / 260).floor(),
    children: [
      RouteNode<FolderRoute>(
        build: (context, folder) => _FolderPage(folder),
        placeholder: (context, folder) =>
            const Scaffold(body: Center(child: Text('Pick a folder'))),
      ),
    ],
  ),
];

/// A folder named by its [path], `Home/Music/Rock`.
final class FolderRoute extends TypedRoute<void> {
  const FolderRoute(this.path);

  final String path;

  @override
  List<Object?> get fields => [path];
}

/// A folder's contents: three subfolders, down to four levels.
final class _FolderPage extends StatelessWidget {
  const _FolderPage(this.folder);

  final FolderRoute folder;

  /// Closes the columns deeper than this folder and opens [child].
  void _open(TypedRouter router, String child) {
    router.popUntil((route) => route == folder);
    router.push(FolderRoute('${folder.path}/$child'));
  }

  @override
  Widget build(BuildContext context) {
    final router = TypedRouter.of(context);
    final depth = folder.path.split('/').length;
    return Scaffold(
      appBar: AppBar(title: Text(folder.path.split('/').last)),
      body: ListView(
        children: [
          const Padding(padding: EdgeInsets.all(8), child: TapCounter()),
          if (depth < 5)
            for (final child in ['Alpha', 'Beta', 'Gamma'])
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(child),
                selected: router.state.routes.contains(
                  FolderRoute('${folder.path}/$child'),
                ),
                onTap: () => _open(router, child),
              )
          else
            const ListTile(title: Text('No subfolders')),
        ],
      ),
    );
  }
}
