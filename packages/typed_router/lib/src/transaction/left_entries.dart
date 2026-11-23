import 'package:typed_router/src/state/navigation_entry.dart';
import 'package:typed_router/src/state/typed_router_state.dart';

/// Finds the entries that left the stack between two states: on screen or in a
/// kept branch stack before, nowhere after. Compared by identity, since an
/// entry is a page.
class LeftEntries {
  /// Creates the comparison.
  const LeftEntries();

  /// The entries of [previous] that [next] does not hold.
  List<NavigationEntry> between(
    TypedRouterState previous,
    TypedRouterState next,
  ) {
    final kept = next.allEntries.toSet();
    return List.unmodifiable(
      previous.allEntries.where((entry) => !kept.contains(entry)),
    );
  }

  /// The entries of [previous]'s stack on screen that [next] does not hold,
  /// from the top down. Entries of branches not on screen are left out.
  List<NavigationEntry> fromScreen(
    TypedRouterState previous,
    TypedRouterState next,
  ) {
    final kept = next.allEntries.toSet();
    return List.unmodifiable(
      previous.entries.reversed.where((entry) => !kept.contains(entry)),
    );
  }
}
