// A redirect limit below zero fails when the router is built.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/typed_navigator.dart';

import '../support/app_fixtures.dart';
import '../support/redirect_fixtures.dart';

void main() {
  test('a negative redirectLimit fails when the router is built', () {
    expect(
      () => TypedRouter(
        routes: sessionRoutes(Session(), []),
        initialRoute: const HomeRoute(),
        pageFactory: const TestPageFactory(),
        redirectLimit: -1,
      ),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'redirectLimit must be 0 or more, got -1.',
        ),
      ),
    );
  });
}
