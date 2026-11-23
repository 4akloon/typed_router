import 'package:flutter/foundation.dart';
import 'package:typed_router/src/transaction/frame_phase.dart';

/// One notification after the current frame, however many changes ask for it
/// while widgets build.
class NotificationAfterFrame {
  /// Creates the schedule on [_framePhase].
  NotificationAfterFrame(this._framePhase);

  final FramePhase _framePhase;
  bool _isScheduled = false;

  /// Runs [notify] after this frame, once for all the requests of the frame.
  void schedule(VoidCallback notify) {
    if (_isScheduled) return;
    _isScheduled = true;
    _framePhase.afterFrame(() {
      _isScheduled = false;
      notify();
    });
  }
}
