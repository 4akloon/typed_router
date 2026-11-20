import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';

/// The tabs' bar: tapping the active tab resets it to its initial route.
final class TabsNavigationBar extends StatelessWidget {
  const TabsNavigationBar(this.shell, {super.key});

  final StatefulShell shell;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: shell.currentIndex,
    onDestinationSelected: (index) => index == shell.currentIndex
        ? shell.resetBranchAt(index)
        : shell.goBranchAt(index),
    destinations: const [
      NavigationDestination(icon: Icon(Icons.meeting_room), label: 'Rooms'),
      NavigationDestination(icon: Icon(Icons.people), label: 'Friends'),
      NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
    ],
  );
}
