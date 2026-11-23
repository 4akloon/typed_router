import 'package:typed_router/src/route/typed_route.dart';

/// A navigation whose redirects loop or go on for more than the router's
/// `redirectLimit`.
///
/// It is a mistake in the app's redirects, found only at runtime. On an
/// operation it is reported and the state stays as it was; when the router
/// is shown or re-checks its stack, the error screen shows it.
///
/// {@category redirects}
class RedirectChainError extends Error {
  /// Creates the error for a [chain] that came back to a route it had
  /// already passed.
  RedirectChainError.loop(List<TypedRoute<Object?>> chain)
    : chain = List.unmodifiable(chain),
      _reason = 'Redirects loop';

  /// Creates the error for a [chain] longer than [redirectLimit]
  /// redirects.
  RedirectChainError.tooLong(
    List<TypedRoute<Object?>> chain, {
    required int redirectLimit,
  }) : chain = List.unmodifiable(chain),
       _reason = 'More than $redirectLimit redirects';

  /// The route the navigation went to, then every route it was redirected
  /// to, in order; the last one is where the chain was stopped.
  final List<TypedRoute<Object?>> chain;

  final String _reason;

  @override
  String toString() =>
      'RedirectChainError: $_reason: ${chain.join(' > ')}. Return null '
      'from a redirect once the target is allowed.';
}
