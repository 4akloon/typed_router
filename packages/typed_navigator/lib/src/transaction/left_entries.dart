import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';

/// Finds the entries that left the stack between two states: on screen or in a
/// kept branch stack before, nowhere after. Compared by identity, since an
/// entry is a page.
class LeftEntries {
  /// Creates the comparison.
  const LeftEntries();

  /// The entries of [previous] that [next] does not hold.
  List<NavigationEntry> between(
    NavigationState previous,
    NavigationState next,
  ) {
    final kept = next.allEntries.toSet();
    return List.unmodifiable(
      previous.allEntries.where((entry) => !kept.contains(entry)),
    );
  }
}
