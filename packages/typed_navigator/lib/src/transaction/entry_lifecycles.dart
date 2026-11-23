import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/state/typed_router_state.dart';
import 'package:typed_navigator/src/transaction/entry_lifecycle.dart';

/// Several lifecycles told about the same entries, in order.
class EntryLifecycles implements EntryLifecycle {
  /// Creates the lifecycle of [_lifecycles], told in this order.
  const EntryLifecycles(this._lifecycles);

  final List<EntryLifecycle> _lifecycles;

  @override
  void entriesLeft(List<NavigationEntry> left, TypedRouterState remains) {
    for (final lifecycle in _lifecycles) {
      lifecycle.entriesLeft(left, remains);
    }
  }

  @override
  void stackDisposed(List<NavigationEntry> entries) {
    for (final lifecycle in _lifecycles) {
      lifecycle.stackDisposed(entries);
    }
  }
}
