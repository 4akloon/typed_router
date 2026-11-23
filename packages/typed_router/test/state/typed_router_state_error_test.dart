// A state that failed its redirects carries the error.

import 'package:flutter_test/flutter_test.dart';

import '../support/route_fixtures.dart';
import '../support/state_fixtures.dart';

void main() {
  final error = StateError('redirect failed');

  test('a state has no error unless the redirects failed', () {
    expect(stateOf(const [RoomsRoute()]).error, isNull);
  });

  test('withError keeps the routes and adds the error', () {
    final state = stateOf(const [RoomsRoute(), RoomRoute(RoomId(7))]);

    final failed = state.withError(error);

    expect(failed.routes, state.routes);
    expect(failed.top, const RoomRoute(RoomId(7)));
    expect(failed.error, same(error));
  });

  test('a state with an error differs from the same state without it', () {
    final state = stateOf(const [RoomsRoute()]);

    expect(state.withError(error), isNot(state));
    expect(state.withError(error), state.withError(error));
    expect(state.withError(error).hashCode, state.withError(error).hashCode);
  });

  test('toString shows the error after the routes', () {
    final state = stateOf(const [RoomsRoute(), RoomRoute(RoomId(7))]);

    expect(
      state.withError(error).toString(),
      'RoomsRoute() > RoomRoute(RoomId(7)) (error: Bad state: redirect failed)',
    );
  });
}
