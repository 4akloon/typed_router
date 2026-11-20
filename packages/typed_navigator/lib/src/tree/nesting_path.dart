import 'package:typed_navigator/src/tree/navigator_slot.dart';
import 'package:typed_navigator/src/tree/nesting.dart';

/// Where a node sits while the tree is walked: the shells and branches around
/// it in the tree, the ones its routes are shown in, and the slots open on the
/// way. An immutable value.
final class NestingPath {
  /// The path at the top of the tree: no nesting, only the root slot.
  const NestingPath.top()
    : guarding = const [],
      shown = const [],
      _slots = const {},
      _slotsBelowShown = const {};

  const NestingPath._(
    this.guarding,
    this.shown,
    this._slots,
    this._slotsBelowShown,
  );

  /// The shells and branches around the node in the tree, outer first:
  /// their redirects guard it.
  final List<Nesting> guarding;

  /// The shells and branches the node's routes are shown in, outer first:
  /// [guarding] cut at a `parentNavigatorSlot`.
  final List<Nesting> shown;

  /// The slots of the navigators in [shown], with the depth of [shown]
  /// that each stands for.
  final Map<NavigatorSlot, int> _slots;

  /// The slots of shells and branches above in the tree whose navigators
  /// are deeper than the one the node is shown in.
  final Set<NavigatorSlot> _slotsBelowShown;

  /// Whether [slot] names a shell or branch above in the tree whose navigator
  /// is deeper than the one the node is shown in: an ancestor route was placed
  /// further out.
  bool isBelowShown(NavigatorSlot slot) => _slotsBelowShown.contains(slot);

  /// This path one [nesting] deeper; [slot] names its navigator.
  NestingPath inside(Nesting nesting, NavigatorSlot? slot) => NestingPath._(
    List.unmodifiable([...guarding, nesting]),
    List.unmodifiable([...shown, nesting]),
    Map.unmodifiable({
      ..._slots,
      ?slot: shown.length + 1,
    }),
    _slotsBelowShown,
  );

  /// This path shown in [slot]'s navigator, or `null` when [slot] is
  /// neither the root nor open on this path (see [isBelowShown]).
  NestingPath? placedIn(NavigatorSlot slot) {
    final depth = identical(slot, NavigatorSlot.root) ? 0 : _slots[slot];
    if (depth == null) return null;
    return NestingPath._(
      guarding,
      List.unmodifiable(shown.take(depth)),
      Map.unmodifiable({
        for (final MapEntry(key: open, value: openDepth) in _slots.entries)
          if (openDepth <= depth) open: openDepth,
      }),
      Set.unmodifiable({
        ..._slotsBelowShown,
        for (final MapEntry(key: open, value: openDepth) in _slots.entries)
          if (openDepth > depth) open,
      }),
    );
  }
}
