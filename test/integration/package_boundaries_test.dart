// What each entry point may import:(no design system in the core)
// and(flutter_test only behind testing.dart, no platform channel helpers of our
// own in test support).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the core imports no design system', () {
    final adapterFolders = {'lib/src/material', 'lib/src/cupertino'};
    final coreFiles = [
      File('lib/typed_navigator.dart'),
      ..._dartFilesIn('lib/src').where(
        (file) => !adapterFolders.any(file.path.startsWith),
      ),
    ];

    expect(coreFiles, hasLength(greaterThan(10)));
    expect(
      _matching(
        coreFiles,
        r"import 'package:flutter/(material|cupertino)\.dart'",
      ),
      isEmpty,
    );
  });

  test('the library outside testing.dart imports no flutter_test', () {
    final testingFiles = [
      File('lib/testing.dart'),
      ..._dartFilesIn('lib/src/testing'),
    ];
    final otherFiles = [
      for (final file in _dartFilesIn('lib'))
        if (!testingFiles.any((testing) => testing.path == file.path)) file,
    ];

    expect(testingFiles, hasLength(greaterThan(1)));
    expect(_matching(otherFiles, 'package:flutter_test/'), isEmpty);
    expect(
      _matching(
        otherFiles,
        r"(import|export) '\S*(testing\.dart|src/testing/)",
      ),
      isEmpty,
    );
  });

  test('test support has no platform channel helpers of its own', () {
    final supportFiles = _dartFilesIn('test/support');

    expect(supportFiles, isNotEmpty);
    expect(
      _matching(
        supportFiles,
        'flutter/backgesture|SystemChannels|handlePlatformMessage|'
        'setMockMethodCallHandler|dragFrom',
      ),
      isEmpty,
    );
  });
}

List<File> _dartFilesIn(String folder) =>
    Directory(folder)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();

List<String> _matching(List<File> files, String pattern) => [
  for (final file in files)
    if (RegExp(pattern).hasMatch(file.readAsStringSync())) file.path,
];
