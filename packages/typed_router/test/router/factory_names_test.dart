// The factory recipes pass the node's name to the page.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router/typed_router.dart';

import '../support/cupertino_page_factory.dart';
import '../support/material_page_factory.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';

Future<String?> _pageNameWith(WidgetTester tester, PageFactory factory) async {
  final router = TypedRouter(
    routes: [
      RouteNode<RoomsRoute>(
        name: 'rooms',
        build: (context, rooms) => const Text('Rooms'),
      ),
    ],
    initialRoute: rooms,
    pageFactory: factory,
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return ModalRoute.of(tester.element(find.text('Rooms')))?.settings.name;
}

void main() {
  testWidgets('MaterialPageFactory names the page after the node', (
    tester,
  ) async {
    expect(await _pageNameWith(tester, const MaterialPageFactory()), 'rooms');
  });

  testWidgets('CupertinoPageFactory names the page after the node', (
    tester,
  ) async {
    expect(await _pageNameWith(tester, const CupertinoPageFactory()), 'rooms');
  });
}
