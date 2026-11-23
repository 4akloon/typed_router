// Helpers for the stack operation tests.

import 'package:flutter/foundation.dart';

import 'route_fixtures.dart';

const rooms = RoomsRoute();
const room7 = RoomRoute(RoomId(7));
const room8 = RoomRoute(RoomId(8));
const editNote = EditNoteRoute();

/// A route the test app has no node for.
const ProfileRoute routeWithoutNode = ProfileRoute('u1', 'games');

/// Records what a result future completed with, without awaiting it, so a
/// test can tell a pending future from a completed one.
class ResultProbe<T> {
  ResultProbe(Future<T?> result) {
    result.then(completions.add);
  }

  /// Every value the future completed with; at most one.
  final List<T?> completions = [];

  bool get isCompleted => completions.isNotEmpty;
}

/// Counts the notifications of a [Listenable].
class NotificationCounter {
  NotificationCounter(Listenable listenable) {
    listenable.addListener(() => count++);
  }

  int count = 0;
}
