import 'package:typed_navigator/typed_navigator.dart';

/// The hall, outside the split.
final class HallRoute extends TypedRoute<void> {
  const HallRoute();

  @override
  List<Object?> get fields => const [];
}

/// The rooms list, the split's first column.
final class RoomsRoute extends TypedRoute<void> {
  const RoomsRoute();

  @override
  List<Object?> get fields => const [];
}

/// A room, the detail column.
final class RoomRoute extends TypedRoute<void> {
  const RoomRoute(this.number);

  final int number;

  @override
  List<Object?> get fields => [number];
}

/// A room's lobby, over the whole split.
final class LobbyRoute extends TypedRoute<void> {
  const LobbyRoute(this.number);

  final int number;

  @override
  List<Object?> get fields => [number];
}

/// The rules, over the whole app.
final class RulesRoute extends TypedRoute<void> {
  const RulesRoute();

  @override
  List<Object?> get fields => const [];
}
