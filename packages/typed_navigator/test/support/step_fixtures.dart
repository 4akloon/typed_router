// Redirect chains: numbered steps under rooms, each redirecting to whatever the
// test says comes next.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import 'app_fixtures.dart';
import 'redirect_fixtures.dart';
import 'route_fixtures.dart';

/// One step of a redirect chain.
class StepRoute extends TypedRoute<void> {
  const StepRoute(this.number);

  final int number;

  @override
  List<Object?> get fields => [number];
}

/// A router whose step nodes redirect to `next(number)`; the router's own
/// [redirect] is optional. Disposed when the test ends.
TypedRouter stepRouter({
  required TypedRoute<Object?>? Function(int number) next,
  TypedRoute<Object?>? Function(BuildContext context, TypedRouterState target)?
  redirect,
  TypedRoute<Object?> initialRoute = const HomeRoute(),
  int redirectLimit = 5,
  Listenable? refreshListenable,
  Widget Function(BuildContext context, Object error)? errorBuilder,
}) {
  final router = TypedRouter(
    routes: [
      RouteNode<HomeRoute>(build: (context, home) => const Text('Home')),
      RouteNode<EditNoteRoute>(
        build: (context, editNote) => const Text('Edit note'),
      ),
      RouteNode<RoomsRoute>(
        build: (context, rooms) => const Text('Rooms'),
        children: [
          RouteNode<StepRoute>(
            build: (context, step) => Text('Step ${step.number}'),
            redirect: (context, step, target) => next(step.number),
          ).withParent((step) => const RoomsRoute()),
        ],
      ),
    ],
    initialRoute: initialRoute,
    pageFactory: const TestPageFactory(),
    redirect: redirect,
    redirectLimit: redirectLimit,
    refreshListenable: refreshListenable,
    errorBuilder: errorBuilder,
  );
  addTearDown(router.dispose);
  return router;
}

/// Steps 0 → 1 → … → [last], then through.
TypedRoute<Object?>? Function(int number) stepsUpTo(int last) =>
    (number) => number < last ? StepRoute(number + 1) : null;
