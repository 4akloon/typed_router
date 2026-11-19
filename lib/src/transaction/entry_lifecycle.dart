import 'package:typed_navigator/src/state/navigation_entry.dart';

/// Learns about stack entries that left the navigation state.
///
/// An entry leaves when a commit no longer holds it (compared by identity)
/// or when the router is disposed. The router operations use this to
/// complete the results of pushed routes.
abstract interface class EntryLifecycle {
  /// A lifecycle that does nothing with the entries.
  const factory EntryLifecycle.ignoring() = _IgnoringEntryLifecycle;

  /// Called once per commit with the [entries] that left, bottom to top.
  /// Not called when no entry left.
  void entriesLeft(List<NavigationEntry> entries);
}

final class _IgnoringEntryLifecycle implements EntryLifecycle {
  const _IgnoringEntryLifecycle();

  @override
  void entriesLeft(List<NavigationEntry> entries) {}
}
