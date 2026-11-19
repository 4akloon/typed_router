import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/navigation_state.dart';
import 'package:typed_navigator/src/transaction/entry_lifecycle.dart';

/// Completes the pushes of entries that leave the state, and of every
/// entry when the router is disposed.
final class ResultCompletion implements EntryLifecycle {
  /// Creates the lifecycle the router uses.
  const ResultCompletion();

  @override
  void entriesLeft(List<NavigationEntry> left, NavigationState remains) =>
      _leave(left);

  @override
  void stackDisposed(List<NavigationEntry> entries) => _leave(entries);

  void _leave(List<NavigationEntry> entries) {
    for (final entry in entries) {
      entry.leave();
    }
  }
}
