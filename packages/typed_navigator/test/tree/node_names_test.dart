// Node names are labels, reach the pages through the factories, and name the
// node in errors.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/operation_fixtures.dart';
import '../support/route_fixtures.dart';

/// A factory that passes the key but forgets the name.
final class _NamelessPageFactory implements PageFactory {
  const _NamelessPageFactory();

  @override
  Page<Object?> createPage(PageRequest request) =>
      TestPage(key: request.key, child: request.child);
}

Future<Object?> _errorOf(WidgetTester tester, PageFactory factory) async {
  final router = TypedRouter(
    routes: [
      RouteNode<RoomsRoute>(
        name: 'rooms list',
        build: (context, rooms) => const Text('Rooms'),
      ),
    ],
    initialRoute: rooms,
    pageFactory: factory,
  );
  addTearDown(router.dispose);
  await pumpWidgetsRouter(tester, router);
  return tester.takeException();
}

void main() {
  testWidgets('two nodes may share a name', (tester) async {
    final router = TypedRouter(
      routes: [
        RouteNode<RoomsRoute>(
          name: 'screen',
          build: (context, rooms) => const Text('Rooms'),
        ),
        RouteNode<AccountRoute>(
          name: 'screen',
          build: (context, account) => const Text('Account'),
        ),
      ],
      initialRoute: rooms,
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);
    router.push(const AccountRoute()).ignore();
    await tester.pumpAndSettle();

    String? nameOf(String text) => ModalRoute.of(
      tester.element(find.text(text, skipOffstage: false)),
    )?.settings.name;
    expect(nameOf('Rooms'), 'screen');
    expect(nameOf('Account'), 'screen');
  });

  testWidgets('an error about a named node names it', (tester) async {
    final error = await _errorOf(tester, const KeylessPageFactory());

    expect(error, isA<StateError>());
    expect('$error', contains('rooms list'));
  });

  testWidgets('a factory that drops request.name fails with its name', (
    tester,
  ) async {
    final error = await _errorOf(tester, const _NamelessPageFactory());

    expect(error, isA<StateError>());
    expect('$error', contains('_NamelessPageFactory'));
    expect('$error', contains('request.name'));
  });

  test('a tree error about a named node names it', () {
    expect(
      () => TypedRouter(
        routes: [
          RouteNode<RoomsRoute>(
            name: 'rooms list',
            parentNavigatorSlot: NavigatorSlot(),
            build: (context, rooms) => const Text('Rooms'),
          ),
        ],
        initialRoute: rooms,
        pageFactory: const TestPageFactory(),
      ),
      throwsA(
        isA<ArgumentError>().having(
          (error) => '${error.message}',
          'message',
          contains('rooms list'),
        ),
      ),
    );
  });
}
