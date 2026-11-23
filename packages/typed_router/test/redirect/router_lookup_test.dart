// A redirect finds the router through its context, as go_router's do since
// 16.2.5.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/typed_router.dart';

import '../support/app_fixtures.dart';
import '../support/step_fixtures.dart';

void main() {
  testWidgets('TypedRouter.of finds the router inside a redirect', (
    tester,
  ) async {
    final found = <TypedRouter>[];
    final router = stepRouter(
      next: (number) => null,
      redirect: (context, target) {
        found.add(TypedRouter.of(context));
        return null;
      },
    );

    await pumpWidgetsRouter(tester, router);
    router.refresh();
    await tester.pumpAndSettle();

    expect(router.state.error, isNull);
    expect(found, hasLength(2));
    expect(found, everyElement(same(router)));
    expect(find.text('Home'), findsOneWidget);
  });
}
