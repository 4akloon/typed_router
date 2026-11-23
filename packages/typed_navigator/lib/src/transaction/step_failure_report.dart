import 'package:flutter/foundation.dart';
import 'package:typed_navigator/src/state/typed_router_state.dart';

/// Reports what a navigation step threw, naming the route the navigation was
/// going to.
class StepFailureReport {
  /// Creates the report.
  const StepFailureReport();

  /// Reports [error] with [stackTrace] through [FlutterError.reportError].
  void report(
    Object error,
    StackTrace stackTrace,
    TypedRouterState candidate,
  ) => FlutterError.reportError(
    FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'typed_navigator',
      context: ErrorDescription('while navigating to ${candidate.top}'),
    ),
  );
}
