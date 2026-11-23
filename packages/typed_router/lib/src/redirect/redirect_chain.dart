import 'package:typed_router/src/redirect/redirect_chain_error.dart';
import 'package:typed_router/src/route/typed_route.dart';

/// The redirects one navigation has followed: stops a loop and a chain longer
/// than the limit.
///
/// Mutable and short-lived: one per navigation, owned by its redirect step.
class RedirectChain {
  /// Starts a chain at the route the navigation went to.
  RedirectChain(TypedRoute<Object?> start, {required this._redirectLimit})
    : _routes = [start];

  final int _redirectLimit;
  final List<TypedRoute<Object?>> _routes;

  /// Adds a redirect to [next]; throws [RedirectChainError] when [next] was
  /// already in the chain or the chain already holds the limit.
  void follow(TypedRoute<Object?> next) {
    final chain = [..._routes, next];
    if (_routes.contains(next)) throw RedirectChainError.loop(chain);
    if (_routes.length > _redirectLimit) {
      throw RedirectChainError.tooLong(chain, redirectLimit: _redirectLimit);
    }
    _routes.add(next);
  }
}
