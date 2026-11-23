// Test doubles for the navigation transaction.

import 'package:flutter/foundation.dart';
import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/src/transaction/entry_lifecycle.dart';
import 'package:typed_navigator/src/transaction/frame_phase.dart';
import 'package:typed_navigator/src/transaction/navigation_controller.dart';
import 'package:typed_navigator/src/transaction/navigation_step.dart';
import 'package:typed_navigator/typed_navigator.dart';

/// A step that returns [replacement] and records what it was given.
class ReplacingStep implements NavigationStep {
  ReplacingStep(this.replacement);

  final NavigationState replacement;
  final List<NavigationState> receivedCandidates = [];

  @override
  NavigationState apply(NavigationState current, NavigationState candidate) {
    receivedCandidates.add(candidate);
    return replacement;
  }
}

/// A step that fails.
class ThrowingStep implements NavigationStep {
  @override
  NavigationState apply(NavigationState current, NavigationState candidate) =>
      throw StateError('The step failed.');
}

/// A step that wrongly navigates from inside the transaction.
class NavigatingStep implements NavigationStep {
  late NavigationController controller;

  @override
  NavigationState apply(NavigationState current, NavigationState candidate) {
    controller.navigate(candidate);
    return candidate;
  }
}

/// A frame phase the test switches by hand.
class ManualFramePhase implements FramePhase {
  @override
  bool isBuilding = false;

  final List<VoidCallback> _afterFrame = [];

  @override
  void afterFrame(VoidCallback callback) => _afterFrame.add(callback);

  /// Ends the frame: runs what waited for it.
  void endFrame() {
    final callbacks = [..._afterFrame];
    _afterFrame.clear();
    for (final callback in callbacks) {
      callback();
    }
  }
}

/// Records every report of entries that left the state.
class RecordingEntryLifecycle implements EntryLifecycle {
  final List<List<NavigationEntry>> reports = [];

  @override
  void entriesLeft(List<NavigationEntry> left, NavigationState remains) =>
      reports.add(left);

  @override
  void stackDisposed(List<NavigationEntry> entries) => reports.add(entries);
}

/// Collects errors reported through [FlutterError.reportError] while a
/// test runs; restores the previous handler afterwards.
class ReportedErrors {
  final List<FlutterErrorDetails> details = [];
  FlutterExceptionHandler? _previousHandler;

  void start() {
    _previousHandler = FlutterError.onError;
    FlutterError.onError = details.add;
  }

  void stop() => FlutterError.onError = _previousHandler;
}
