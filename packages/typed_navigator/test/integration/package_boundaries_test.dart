// What the core package may depend on and import:(no test or design system
// package)(no design system in the core) and(no platform channel helpers of our
// own in test support).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _forbiddenPackages = [
  'cupertino_ui',
  'flutter_test',
  'material_ui',
  // Brings flutter_test along.
  'typed_navigator_test',
];

void main() {
  test('the core depends on no test or design system package', () {
    final dependencies = _dependenciesIn(File('pubspec.yaml'));

    expect(dependencies, contains('flutter'));
    expect(dependencies.where(_forbiddenPackages.contains), isEmpty);
  });

  test('the core imports no test or design system library', () {
    final libraryFiles = _dartFilesIn('lib');

    expect(libraryFiles, hasLength(greaterThan(10)));
    expect(
      _matching(
        libraryFiles,
        "(import|export) 'package:("
        '${_forbiddenPackages.join('|')}'
        r'|flutter/(material|cupertino)\.dart)',
      ),
      isEmpty,
    );
  });

  test('the core has one entry point', () {
    expect(
      Directory('lib').listSync().whereType<File>().map((file) => file.path),
      ['lib/typed_navigator.dart'],
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

/// The package names under `dependencies:` (not `dev_dependencies:`).
List<String> _dependenciesIn(File pubspec) {
  final section = RegExp(
    r'^dependencies:\n((?:[ #].*\n|\n)*)',
    multiLine: true,
  ).firstMatch(pubspec.readAsStringSync());
  final body = section?.group(1) ?? '';
  return [
    for (final match in RegExp(r'^  (\w+):', multiLine: true).allMatches(body))
      match.group(1) ?? '',
  ];
}

List<File> _dartFilesIn(String folder) => Directory(folder)
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.dart'))
    .toList();

List<String> _matching(List<File> files, String pattern) => [
  for (final file in files)
    if (RegExp(pattern).hasMatch(file.readAsStringSync())) file.path,
];
