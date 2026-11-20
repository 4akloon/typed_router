// What the test package may import. It reaches the router only through
// typed_navigator's public entry, never its `src/`.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the test package imports only the public entry of the core', () {
    final libraryFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
    final coreImport = RegExp(
      r"(import|export) 'package:typed_navigator/(\S+)'",
    );

    expect(libraryFiles, hasLength(greaterThan(3)));
    expect(
      [
        for (final file in libraryFiles)
          for (final match in coreImport.allMatches(file.readAsStringSync()))
            if (match.group(2) != 'typed_navigator.dart') file.path,
      ],
      isEmpty,
    );
  });

  test('the test package has one entry point', () {
    expect(
      Directory('lib').listSync().whereType<File>().map((file) => file.path),
      ['lib/typed_navigator_test.dart'],
    );
  });
}
