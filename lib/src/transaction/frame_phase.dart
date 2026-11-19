import 'package:flutter/scheduler.dart';

/// Tells whether the framework is building widgets right now.
///
/// Navigating while widgets build is an error, as in the native
/// `Navigator`. The router asks this only when a navigation is requested,
/// never when it is created, so a router can exist before the binding.
abstract interface class FramePhase {
  /// The phase reported by [SchedulerBinding].
  const factory FramePhase.scheduler() = _SchedulerFramePhase;

  /// Whether the current frame is in its build phase.
  bool get isBuilding;
}

final class _SchedulerFramePhase implements FramePhase {
  const _SchedulerFramePhase();

  @override
  bool get isBuilding =>
      SchedulerBinding.instance.schedulerPhase ==
      SchedulerPhase.persistentCallbacks;
}
