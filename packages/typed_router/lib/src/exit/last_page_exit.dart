import 'dart:async';

import 'package:flutter/services.dart';
import 'package:typed_router/src/exit/exit_questions.dart';
import 'package:typed_router/src/state/navigation_entry.dart';
import 'package:typed_router/src/state/typed_router_state.dart';

/// Back on the router's only page whose node has `onExit`: asks it, as
/// go_router's `popRoute` does, and closes the app on `true`, unless the state
/// changed while it was asked.
class LastPageExit {
  /// Creates the exit that asks through [_questions].
  LastPageExit(this._questions);

  final ExitQuestions _questions;

  /// Asks the `onExit` of [entry], the only page of the state [state] gives,
  /// and closes the app on `true`.
  void ask(NavigationEntry entry, TypedRouterState Function() state) {
    final asked = state();
    void closeIfStill(bool mayLeave) {
      if (mayLeave && identical(state(), asked)) {
        unawaited(SystemNavigator.pop());
      }
    }

    switch (_questions.mayClose(entry, asked)) {
      case final bool mayLeave:
        closeIfStill(mayLeave);
      case final Future<bool> later:
        unawaited(later.then(closeIfStill));
    }
  }
}
