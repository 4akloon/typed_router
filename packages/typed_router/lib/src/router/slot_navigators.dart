import 'package:flutter/widgets.dart';
import 'package:typed_router/src/state/typed_router_state.dart';
import 'package:typed_router/src/tree/navigator_slot.dart';

/// Finds the navigator of a slot for code outside the shell's widgets, as
/// go_router apps use a shell's navigator key.
///
/// A slot names every instance of its shell or branch; the one on the active
/// path nearest the top is the one asked for. Each router finds its own, so
/// several routers never meet.
class SlotNavigators {
  /// Creates the lookup.
  const SlotNavigators();

  /// The navigator of [slot] in [state] under [root]: [root] for
  /// `NavigatorSlot.root`; `null` while the router is not shown, or when no
  /// level of [slot] stands on the active path.
  NavigatorState? of(
    NavigatorSlot slot,
    NavigatorState? root,
    TypedRouterState state,
  ) {
    if (root == null) return null;
    if (identical(slot, NavigatorSlot.root)) return root;
    for (final entry in state.entries.reversed) {
      for (final level in entry.levels.reversed) {
        if (identical(level.slot, slot)) {
          return level.navigatorKey.currentState;
        }
      }
    }
    return null;
  }
}
