// Page factories. That the core imports no design system is guarded in
// package_boundaries_test.dart.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/src/page/page_request.dart';

import '../support/app_fixtures.dart';
import '../support/cupertino_page_factory.dart';
import '../support/material_page_factory.dart';
import '../support/route_fixtures.dart';

void main() {
  testWidgets("a node's page factory overrides the router's", (tester) async {
    await pumpWidgetsRouter(tester, appRouter(const CreateRoomRoute()));

    expect(pageShowing(tester, 'Create room'), isA<SheetPage>());
    expect(
      pageShowing(tester, 'Rooms'),
      allOf(isA<TestPage>(), isNot(isA<SheetPage>())),
    );
  });

  testWidgets('a factory that drops the request key fails with its name and '
      'the route', (tester) async {
    final router = appRouter(
      const RoomsRoute(),
      pageFactory: const KeylessPageFactory(),
    );

    await pumpWidgetsRouter(tester, router);

    expect(
      tester.takeException(),
      isA<StateError>().having(
        (error) => error.message,
        'message',
        allOf(contains('KeylessPageFactory'), contains('RoomsRoute()')),
      ),
    );
  });

  test('MaterialPageFactory and CupertinoPageFactory create their pages '
      'with the request key', () {
    const request = PageRequest(key: ValueKey('entry'), child: Text('Room'));

    final materialPage = const MaterialPageFactory(
      fullscreenDialog: true,
    ).createPage(request);
    final cupertinoPage = const CupertinoPageFactory().createPage(request);

    expect(
      materialPage,
      isA<MaterialPage<Object?>>()
          .having((page) => page.key, 'key', request.key)
          .having((page) => page.child, 'child', request.child)
          .having((page) => page.fullscreenDialog, 'fullscreenDialog', true),
    );
    expect(
      cupertinoPage,
      isA<CupertinoPage<Object?>>()
          .having((page) => page.key, 'key', request.key)
          .having((page) => page.child, 'child', request.child)
          .having((page) => page.fullscreenDialog, 'fullscreenDialog', false),
    );
  });
}
