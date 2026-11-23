// The router shown by MaterialApp.router and WidgetsApp.router: redirects keep
// running when the router moves to another place in the tree.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/app_fixtures.dart';
import '../support/material_page_factory.dart';
import '../support/redirect_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/step_fixtures.dart';

void main() {
  testWidgets('MaterialApp.router shows the initial screen above its '
      'ancestors', (tester) async {
    final router = appRouter(
      const RoomRoute(RoomId(7)),
      pageFactory: const MaterialPageFactory(),
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Room 7'), findsOneWidget);
    expect(find.text('Rooms'), findsNothing);
    expect(find.text('Rooms', skipOffstage: false), findsOneWidget);
  });

  testWidgets('WidgetsApp.router with a widgets-only factory shows the same '
      'stack', (tester) async {
    final router = appRouter(const RoomRoute(RoomId(7)));

    await pumpWidgetsRouter(tester, router);

    expect(find.text('Room 7'), findsOneWidget);
    expect(find.text('Rooms', skipOffstage: false), findsOneWidget);
    expect(pageShowing(tester, 'Room 7'), isA<TestPage>());
  });

  testWidgets('a screen is built from its node with the typed route', (
    tester,
  ) async {
    final router = appRouter(const RoomRoute(RoomId(42)));

    await pumpWidgetsRouter(tester, router);

    expect(find.text('Room 42'), findsOneWidget);
    expect(
      ModalRoute.of(tester.element(find.text('Room 42')))?.isCurrent,
      isTrue,
    );
  });

  testWidgets('redirects keep running when the router is shown in another '
      'place', (tester) async {
    var calls = 0;
    final router = stepRouter(
      next: (number) => null,
      redirect: (context, target) {
        calls++;
        return null;
      },
    );
    Widget app() => WidgetsApp.router(
      routerConfig: router,
      color: const Color(0xFF000000),
    );
    Widget placed(Widget Function(List<Widget> children) parent) =>
        Directionality(
          textDirection: TextDirection.ltr,
          child: parent([Expanded(child: app())]),
        );
    await tester.pumpWidget(placed((children) => Column(children: children)));
    // A new place: the new scope attaches before the old one leaves.
    await tester.pumpWidget(placed((children) => Row(children: children)));
    calls = 0;

    router.push(const RoomsRoute()).ignore();
    await tester.pumpAndSettle();

    expect(calls, greaterThan(0));
    expect(find.text('Rooms'), findsOneWidget);
    expect(router.state.routes, const [HomeRoute(), RoomsRoute()]);
  });
}
