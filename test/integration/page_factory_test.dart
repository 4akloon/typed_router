// Page factories.

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/cupertino.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/src/page/page_request.dart';

import '../support/app_fixtures.dart';
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

  test('the core imports no design system', () {
    final adapterFolders = {'lib/src/material', 'lib/src/cupertino'};
    final coreFiles = [
      File('lib/typed_navigator.dart'),
      ...Directory('lib/src')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (file) =>
                file.path.endsWith('.dart') &&
                !adapterFolders.any(file.path.startsWith),
          ),
    ];

    final importingDesignSystems = [
      for (final file in coreFiles)
        if (RegExp(
          r"import 'package:flutter/(material|cupertino)\.dart'",
        ).hasMatch(file.readAsStringSync()))
          file.path,
    ];

    expect(coreFiles, hasLength(greaterThan(10)));
    expect(importingDesignSystems, isEmpty);
  });
}
