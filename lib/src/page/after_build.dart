import 'package:flutter/scheduler.dart';

/// Runs an action once the frame's build is done: at once when the frame
/// is already past it, else after the frame. Requests made before the
/// action runs share one run.
///
/// For work that reads or changes routes, which Flutter does not allow while it
/// builds.
final class AfterBuild {
  /// Creates a runner of [_action].
  AfterBuild(this._action);

  final void Function() _action;
  bool _isScheduled = false;

  /// Runs the action now if the build is done, else after the frame,
  /// unless [isWanted] says no by then (the widget was disposed).
  void request({required bool Function() isWanted}) {
    final binding = SchedulerBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.postFrameCallbacks) {
      _action();
      return;
    }
    if (_isScheduled) return;
    _isScheduled = true;
    binding.addPostFrameCallback((timeStamp) {
      _isScheduled = false;
      if (isWanted()) _action();
    }, debugLabel: 'typed_navigator.AfterBuild');
  }
}
