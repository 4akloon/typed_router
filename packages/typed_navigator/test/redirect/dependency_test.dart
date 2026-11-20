// A redirect gets the Router's context, and an inherited widget it depends on
// re-runs it.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/redirect_fixtures.dart';

void main() {
  testWidgets('a redirect re-runs when an inherited widget it depends on '
      'changes', (tester) async {
    final watching = await _pumpMaintenance(tester, isWatching: true);
    final reading = await _pumpMaintenance(tester, isWatching: false);

    expect(watching.state.routes, const [BannedRoute()]);
    expect(reading.state.routes, const [rooms, room7]);
  });
}

/// Shows a router whose redirect reads [_Maintenance], then turns
/// maintenance on.
Future<TypedRouter> _pumpMaintenance(
  WidgetTester tester, {
  required bool isWatching,
}) async {
  final router = TypedRouter(
    routes: sessionRoutes(Session(isSignedIn: true), []),
    initialRoute: room7,
    pageFactory: const TestPageFactory(),
    redirect: (context, target) {
      final maintenance = isWatching
          ? context.dependOnInheritedWidgetOfExactType<_Maintenance>()
          : context.getInheritedWidgetOfExactType<_Maintenance>();
      return maintenance?.isOn ?? false ? const BannedRoute() : null;
    },
  );
  addTearDown(router.dispose);
  Widget app({required bool isOn}) => _Maintenance(
    isOn: isOn,
    child: WidgetsApp.router(
      routerConfig: router,
      color: const Color(0xFF000000),
    ),
  );
  await tester.pumpWidget(app(isOn: false));
  await tester.pumpWidget(app(isOn: true));
  await tester.pumpAndSettle();
  return router;
}

final class _Maintenance extends InheritedWidget {
  const _Maintenance({required this.isOn, required super.child});

  final bool isOn;

  @override
  bool updateShouldNotify(_Maintenance oldWidget) => oldWidget.isOn != isOn;
}
