import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/shell_level.dart';

/// A part of a navigator's stack: one route page, or the entries of one level
/// (a shell instance or a branch of tabs) shown in a nested navigator.
sealed class StackPart {
  const StackPart();
}

/// A page of a route in this navigator.
class RoutePart extends StackPart {
  /// Creates the part of [entry].
  const RoutePart(this.entry);

  /// The entry shown by the page.
  final NavigationEntry entry;
}

/// Entries one after another in the same [level], shown by one page of
/// this navigator that holds the level's navigator.
class LevelPart extends StackPart {
  /// Creates the part of [entries] in [level].
  const LevelPart(this.level, this.entries);

  /// The level the entries stand in.
  final ShellLevel level;

  /// The entries, bottom to top.
  final List<NavigationEntry> entries;
}

/// Splits the entries of one navigator into its parts: a route at [depth]
/// is its own page; entries that stand in the same level at [depth], one
/// after another, are one part.
class StackParts {
  /// Creates the splitter.
  const StackParts();

  /// The parts of [entries], which all share their levels above [depth].
  List<StackPart> of(List<NavigationEntry> entries, int depth) {
    final parts = <StackPart>[];
    var index = 0;
    while (index < entries.length) {
      final entry = entries[index];
      if (entry.levels.length == depth) {
        parts.add(RoutePart(entry));
        index++;
        continue;
      }
      final level = entry.levels[depth];
      final group = entries
          .skip(index)
          .takeWhile(
            (member) =>
                member.levels.length > depth &&
                identical(member.levels[depth], level),
          )
          .toList();
      parts.add(LevelPart(level, group));
      index += group.length;
    }
    return parts;
  }
}
