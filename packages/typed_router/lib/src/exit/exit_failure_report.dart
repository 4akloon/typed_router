import 'package:flutter/foundation.dart';

/// Reports what a node's `onExit` threw, or the error its `Future` completed
/// with, naming the page that was asked.
class ExitFailureReport {
  /// Creates the report.
  const ExitFailureReport();

  /// Reports [error] with [stackTrace] through [FlutterError.reportError];
  /// [page] names the page whose `onExit` failed.
  void report(Object error, StackTrace stackTrace, String page) =>
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'typed_router',
          context: ErrorDescription('while asking onExit of $page'),
        ),
      );
}
