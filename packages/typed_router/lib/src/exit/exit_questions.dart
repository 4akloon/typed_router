import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:typed_router/src/exit/exit_failure_report.dart';
import 'package:typed_router/src/state/navigation_entry.dart';
import 'package:typed_router/src/state/typed_router_state.dart';
import 'package:typed_router/src/transaction/left_entries.dart';
import 'package:typed_router/src/tree/route_tree.dart';

/// Asks the `onExit` of the pages a navigation removes from the stack on
/// screen, from the top down, as go_router does: the first `false` stops.
///
/// The answer stays synchronous while every hook answers with a `bool`. A hook
/// that answers with a `Future` keeps its question open until it completes;
/// a navigation asking about the same page meanwhile gets that answer rather
/// than a second question. A hook that fails is reported and refuses.
class ExitQuestions {
  /// Creates the questions for pages of [_tree], asked with the context
  /// [_context] gives (the root navigator's; `null` while the router is not
  /// shown, when nobody is asked).
  ExitQuestions(this._tree, this._context);

  final RouteTree _tree;
  final BuildContext? Function() _context;
  final LeftEntries _leftEntries = const LeftEntries();
  final ExitFailureReport _failureReport = const ExitFailureReport();
  final Map<NavigationEntry, Future<bool>> _open = {};
  bool _isAsking = false;

  /// Whether a hook is being called right now.
  bool get isAsking => _isAsking;

  /// Whether every page that leaves the screen between [current] and
  /// [target] may go.
  FutureOr<bool> mayLeave(TypedRouterState current, TypedRouterState target) {
    final context = _context();
    if (context == null) return true;
    final asking = _leftEntries
        .fromScreen(current, target)
        .where((entry) => _tree.nodeFor(entry.route).asksOnExit)
        .toList();
    return _askFrom(0, asking, context, target);
  }

  /// Whether [entry], the only page of [state], may go as back leaves the
  /// app: its `onExit` with [state] as the target, as go_router asks it.
  FutureOr<bool> mayClose(NavigationEntry entry, TypedRouterState state) {
    final context = _context();
    if (context == null) return true;
    return _answerOf(entry, context, state);
  }

  FutureOr<bool> _askFrom(
    int index,
    List<NavigationEntry> asking,
    BuildContext context,
    TypedRouterState target,
  ) {
    if (index == asking.length) return true;
    FutureOr<bool> next(bool mayGo) =>
        mayGo ? _askFrom(index + 1, asking, context, target) : false;
    return switch (_answerOf(asking[index], context, target)) {
      final bool mayGo => next(mayGo),
      final Future<bool> later => later.then(next),
    };
  }

  FutureOr<bool> _answerOf(
    NavigationEntry entry,
    BuildContext context,
    TypedRouterState target,
  ) {
    if (_open[entry] case final open?) return open;
    final node = _tree.nodeFor(entry.route);
    final FutureOr<bool> answer;
    _isAsking = true;
    try {
      answer = node.exitAnswerFor(context, entry.route, target);
    } catch (error, stackTrace) {
      // The one place besides the controller's steps that catches whatever
      // the app's code throws: reported, and taken as a refusal.
      _failureReport.report(error, stackTrace, node.describe(entry.route));
      return false;
    } finally {
      _isAsking = false;
    }
    if (answer is bool) return answer;
    final later = answer.then(
      (mayGo) => mayGo,
      onError: (Object error, StackTrace stackTrace) {
        _failureReport.report(error, stackTrace, node.describe(entry.route));
        return false;
      },
    );
    _open[entry] = later;
    unawaited(
      later.whenComplete(() {
        if (identical(_open[entry], later)) _open.remove(entry);
      }),
    );
    return later;
  }
}
