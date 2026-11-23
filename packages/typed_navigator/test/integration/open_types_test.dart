// The public types are open to apps: a fake router for code
// the app hands the router to, nodes declared as classes of a feature module, a
// fake state for app code that reads one, as go_router's classes allow. A
// redirect's target still comes from `stateAfterGo`: a made-up target can lack
// the ancestors a redirect sees.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';

/// A router fake that records pushes, as apps fake `GoRouter`.
class _RecordingRouter extends Fake implements TypedRouter {
  final List<TypedRoute<Object?>> pushed = [];

  @override
  Future<T?> push<T>(TypedRoute<T> route) {
    pushed.add(route);
    return Future.value();
  }
}

/// A node a feature module declares as a class of its own.
class _RoomsNode extends RouteNode<RoomsRoute> {
  const _RoomsNode() : super(build: _buildRooms);

  static Widget _buildRooms(BuildContext context, RoomsRoute route) =>
      const Text('Rooms');
}

/// A state an app's unit test makes up for its own code.
class _OnAccount extends Fake implements TypedRouterState {
  @override
  TypedRoute<Object?> get top => const AccountRoute();
}

/// App code that reads a state: the screen name for analytics.
String _screenName(TypedRouterState state) =>
    state.top is AuthArea ? 'private' : 'public';

void main() {
  test('an app can fake the router in its tests', () {
    final router = _RecordingRouter();

    router.push(room7).ignore();

    expect(router.pushed, const [room7]);
  });

  testWidgets('an app can declare its nodes as classes', (tester) async {
    final router = TypedRouter(
      routes: const [_RoomsNode()],
      initialRoute: rooms,
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);

    await pumpWidgetsRouter(tester, router);

    expect(find.text('Rooms'), findsOneWidget);
  });

  test("app code that reads a state can be tested with the app's own", () {
    expect(_screenName(_OnAccount()), 'private');
  });

  test("the router's state is not equal to an app's own, and does not "
      'throw', () {
    final router = appRouter(rooms);

    expect(router.state == _OnAccount(), isFalse);
    expect(_OnAccount() == router.state, isFalse);
  });
}
