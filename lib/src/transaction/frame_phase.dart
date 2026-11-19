import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Tells whether the framework is building widgets right now.
///
/// Navigating while widgets build is an error, as in the native
/// `Navigator`. The router asks this only inside debug assertions, when a
/// navigation is requested, so a router can exist and navigate before the
/// binding (in `main`, before `runApp`).
abstract interface class FramePhase {
  /// The phase reported by [SchedulerBinding]; not building while there is
  /// no binding yet.
  const factory FramePhase.scheduler() = _SchedulerFramePhase;

  /// Whether the current frame is in its build phase.
  bool get isBuilding;

  /// Calls [callback] once the current frame is done.
  void afterFrame(VoidCallback callback);
}

final class _SchedulerFramePhase implements FramePhase {
  const _SchedulerFramePhase();

  /// [BindingBase.debugBindingType] answers only in debug builds, which is
  /// where this is asked: inside an `assert`.
  @override
  bool get isBuilding =>
      BindingBase.debugBindingType() != null &&
      SchedulerBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks;

  @override
  void afterFrame(VoidCallback callback) =>
      SchedulerBinding.instance.addPostFrameCallback((_) => callback());
}
