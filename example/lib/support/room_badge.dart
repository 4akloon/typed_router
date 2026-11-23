import 'package:material_ui/material_ui.dart';

/// The door of the rooms: small on the list, large in a room. Its hero flies
/// between them inside the tab's navigator, which has a hero controller of its
/// own.
class RoomBadge extends StatelessWidget {
  const RoomBadge({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => Hero(
    tag: 'room badge',
    child: Icon(Icons.meeting_room, key: const Key('room badge'), size: size),
  );
}
