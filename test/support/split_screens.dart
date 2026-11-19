// The routes and screens of the split app. Screens count taps and log creation,
// so a test sees whether a screen kept its state.

import 'package:flutter/widgets.dart';
import 'package:typed_navigator/typed_navigator.dart';

import 'tabs_fixtures.dart';

/// A player of a room; returns a verdict.
final class PlayerRoute extends TypedRoute<String> {
  const PlayerRoute(this.roomId, this.name);

  final int roomId;
  final String name;

  @override
  List<Object?> get fields => [roomId, name];
}

/// A room's lobby, shown over the whole split.
final class LobbyRoute extends TypedRoute<void> {
  const LobbyRoute(this.roomId);

  final int roomId;

  @override
  List<Object?> get fields => [roomId];
}

/// The rules, shown over the whole app.
final class RulesRoute extends TypedRoute<void> {
  const RulesRoute();

  @override
  List<Object?> get fields => const [];
}

/// A screen that shows `label:taps`, counts taps and logs its creation.
final class CountingScreen extends StatefulWidget {
  const CountingScreen(this.label, this.log, {super.key});

  final String label;
  final ScreenLog log;

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

final class _CountingScreenState extends State<CountingScreen> {
  int _taps = 0;

  @override
  void initState() {
    super.initState();
    widget.log.created.add(widget.label);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => _taps++),
    child: Text('${widget.label}:$_taps'),
  );
}
