import 'package:flutter/material.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/support/demo_button.dart';
import 'package:typed_navigator_example/support/demo_page.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const typedResultsScenario = Scenario(
  title: 'Typed results',
  summary: 'push returns Future<T?>; pop completes it with a T.',
  instructions: [
    '"Edit name" pushes EditNameRoute, a TypedRoute<String>: the profile '
        'awaits a String.',
    'Save with router.pop or with the native Navigator.pop: both return '
        'the text, the profile shows it.',
    'Leave with back (app bar, System back, swipe): the push completes '
        'with null and the name stays.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () => TypedRouter(
    routes: [
      RouteNode<ProfileRoute>(
        build: (context, profile) => const _ProfilePage(),
      ),
      RouteNode<EditNameRoute>(
        build: (context, edit) => _EditNamePage(edit.current),
      ),
    ],
    initialRoute: const ProfileRoute(),
    pageFactory: const MaterialPageFactory(),
  ),
);

final class ProfileRoute extends TypedRoute<void> {
  const ProfileRoute();

  @override
  List<Object?> get fields => const [];
}

/// Returns the new name when popped.
final class EditNameRoute extends TypedRoute<String> {
  const EditNameRoute(this.current);

  final String current;

  @override
  List<Object?> get fields => [current];
}

final class _ProfilePage extends StatefulWidget {
  const _ProfilePage();

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

final class _ProfilePageState extends State<_ProfilePage> {
  String _name = 'Ann';
  String _lastResult = 'nothing yet';

  Future<void> _editName() async {
    final String? name = await TypedRouter.of(
      context,
    ).push(EditNameRoute(_name));
    // Closing the demo disposes the router, which completes the push.
    if (!mounted) return;
    setState(() {
      _lastResult = name == null ? 'null' : '"$name"';
      _name = name ?? _name;
    });
  }

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'Profile',
    text: 'Name: $_name\nLast result of the push: $_lastResult',
    actions: [DemoButton('Edit name', onPressed: _editName)],
  );
}

final class _EditNamePage extends StatefulWidget {
  const _EditNamePage(this.current);

  final String current;

  @override
  State<_EditNamePage> createState() => _EditNamePageState();
}

final class _EditNamePageState extends State<_EditNamePage> {
  late final TextEditingController _name = TextEditingController(
    text: widget.current,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'Edit name',
    actions: [
      TextField(controller: _name),
      DemoButton(
        'Save with router.pop',
        onPressed: () => TypedRouter.of(context).pop(_name.text),
      ),
      DemoButton(
        'Save with Navigator.pop',
        onPressed: () => Navigator.pop(context, _name.text),
      ),
    ],
  );
}
