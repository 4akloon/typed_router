import 'package:typed_navigator/src/operation/shell_path.dart';
import 'package:typed_navigator/src/result/pending_result.dart';
import 'package:typed_navigator/src/route/typed_route.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/shell_level.dart';

/// Makes new stack entries with their levels.
class EntryChain {
  /// Creates entries whose levels [_shellPath] decides.
  EntryChain(this._shellPath);

  final ShellPath _shellPath;

  /// [kept] followed by a new entry for every route of [chain], each right
  /// above the previous one; the first may take over the levels of one of
  /// [replaceable], the rest join it.
  List<NavigationEntry> chained(
    List<NavigationEntry> kept,
    Iterable<TypedRoute<Object?>> chain, {
    Iterable<List<ShellLevel>> replaceable = const [],
  }) {
    final entries = [...kept];
    for (final (index, route) in chain.indexed) {
      entries.add(
        entryAbove(
          entries.lastOrNull?.levels ?? const [],
          route,
          replaceable: index == 0 ? replaceable : const [],
        ),
      );
    }
    return entries;
  }

  /// A new entry for [route] right above an entry inside [below];
  /// [pendingResult] when a push awaits it.
  NavigationEntry entryAbove(
    List<ShellLevel> below,
    TypedRoute<Object?> route, {
    Iterable<List<ShellLevel>> replaceable = const [],
    PendingResult<Object?>? pendingResult,
  }) => NavigationEntry(
    route,
    levels: _shellPath.levelsFor(
      route,
      below: below,
      replaceable: replaceable,
    ),
    pendingResult: pendingResult,
  );
}
