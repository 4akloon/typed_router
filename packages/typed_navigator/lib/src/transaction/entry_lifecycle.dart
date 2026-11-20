import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';

/// Learns about stack entries that left the navigation state.
///
/// An entry leaves when a commit no longer holds it (compared by identity, on
/// screen or in a kept branch stack) or when the router is disposed. The router
/// uses this to complete the results of pushed routes and to close what is left
/// in navigators that are gone.
abstract interface class EntryLifecycle {
  /// A lifecycle that does nothing with the entries.
  const factory EntryLifecycle.ignoring() = _IgnoringEntryLifecycle;

  /// Called once per commit with the entries that [left], bottom to top,
  /// and the state that [remains]. Not called when no entry left.
  void entriesLeft(List<NavigationEntry> left, NavigationState remains);

  /// Called once when the router is disposed, with every entry it held.
  void stackDisposed(List<NavigationEntry> entries);
}

final class _IgnoringEntryLifecycle implements EntryLifecycle {
  const _IgnoringEntryLifecycle();

  @override
  void entriesLeft(List<NavigationEntry> left, NavigationState remains) {}

  @override
  void stackDisposed(List<NavigationEntry> entries) {}
}
