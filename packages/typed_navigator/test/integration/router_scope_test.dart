// An app puts its own router above widgets with TypedRouterScope, as
// go_router's InheritedGoRouter, so a widget test can hand a screen a fake
// router.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/route_fixtures.dart';

class _OnAccount extends Fake implements NavigationState {
  @override
  TypedRoute<Object?> get top => const AccountRoute();
}

class _FakeRouter extends Fake implements TypedRouter {
  final List<TypedRoute<Object?>> pushed = [];

  @override
  NavigationState get state => _OnAccount();

  @override
  Future<T?> push<T>(TypedRoute<T> route) {
    pushed.add(route);
    return Future.value();
  }
}

/// A screen that reads the router and the state as an app's screen does.
class _AccountButton extends StatelessWidget {
  const _AccountButton();

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => TypedRouter.of(context).push(const RoomsRoute()).ignore(),
    child: Text('On ${NavigationState.of(context).top}'),
  );
}

void main() {
  testWidgets('a fake router in TypedRouterScope is found by TypedRouter.of '
      'and NavigationState.of', (tester) async {
    final router = _FakeRouter();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: TypedRouterScope(router: router, child: const _AccountButton()),
      ),
    );
    await tester.tap(find.text('On AccountRoute()'));

    expect(router.pushed, const [RoomsRoute()]);
  });
}
