// The page factory recipes in the README compile. The tests' own factories are
// the README's code, verbatim, so a recipe that drifts from them, or from the
// API, fails here or in the build.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final recipes = RegExp(
    r'```dart\n(.*?)```',
    dotAll: true,
  ).allMatches(File('README.md').readAsStringSync()).map((match) => match[1]);

  for (final (factory, file) in [
    ('MaterialPageFactory', 'material_page_factory.dart'),
    ('CupertinoPageFactory', 'cupertino_page_factory.dart'),
  ]) {
    test('the README recipe for $factory is the code the tests run', () {
      final recipe = recipes.singleWhere(
        (code) => code?.contains('class $factory implements') ?? false,
      );

      expect(
        File('test/support/$file').readAsStringSync(),
        endsWith('$recipe'),
      );
    });
  }
}
