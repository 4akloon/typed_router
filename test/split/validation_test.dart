// Misuse fails when the router or the split is built.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/split_fixtures.dart';

void main() {
  test('a split without children fails when the router is built', () {
    expect(
      () => TypedRouter(
        routes: [
          SplitNode<NoParentRoute>(
            maximumColumns: (size) => 2,
            children: const [],
          ),
        ],
        initialRoute: rooms,
        pageFactory: const TestPageFactory(),
      ),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          contains('A SplitNode has no children'),
        ),
      ),
    );
  });

  testWidgets('a negative maximumColumns fails with the number', (
    tester,
  ) async {
    final router = TypedRouter(
      routes: [
        SplitNode<NoParentRoute>(
          maximumColumns: (size) => -1,
          children: [
            RouteNode<RoomsRoute>(build: (context, _) => const Text('R')),
          ],
        ),
      ],
      initialRoute: rooms,
      pageFactory: const TestPageFactory(),
    );
    addTearDown(router.dispose);
    await pumpWidgetsRouter(tester, router);

    expect(
      tester.takeException(),
      isA<ArgumentError>().having(
        (error) => error.message,
        'message',
        contains('maximumColumns returned -1'),
      ),
    );
  });
}
