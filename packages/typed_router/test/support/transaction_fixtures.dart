// Test doubles for the navigation transaction.

import 'package:flutter/foundation.dart';
import 'package:typed_router/src/state/navigation_entry.dart';
import 'package:typed_router/src/transaction/entry_lifecycle.dart';
import 'package:typed_router/src/transaction/frame_phase.dart';
import 'package:typed_router/src/transaction/navigation_controller.dart';
import 'package:typed_router/src/transaction/navigation_step.dart';
import 'package:typed_router/typed_router.dart';

/// A step that returns [replacement] and records what it was given.
class ReplacingStep implements NavigationStep {
  ReplacingStep(this.replacement);

  final TypedRouterState replacement;
  final List<TypedRouterState> receivedCandidates = [];

  @override
  TypedRouterState apply(TypedRouterState current, TypedRouterState candidate) {
    receivedCandidates.add(candidate);
    return replacement;
  }
}

/// A step that fails.
class ThrowingStep implements NavigationStep {
  @override
  TypedRouterState apply(
    TypedRouterState current,
    TypedRouterState candidate,
  ) => throw StateError('The step failed.');
}

/// A step that wrongly navigates from inside the transaction.
class NavigatingStep implements NavigationStep {
  late NavigationController controller;

  @override
  TypedRouterState apply(TypedRouterState current, TypedRouterState candidate) {
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
  void entriesLeft(List<NavigationEntry> left, TypedRouterState remains) =>
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
