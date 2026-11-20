// One back closes one thing; a pageless route in a column to the left of the
// deepest goes first.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/testing.dart';

import '../support/column_back_fixtures.dart';
import '../support/operation_fixtures.dart' show ResultProbe;
import '../support/split_fixtures.dart';

const _all = '[RoomsRoute() > RoomRoute(RoomId(1)) > PlayerRoute(1, ann)]';

/// Opens a sheet titled [sheet] in the column of the page titled [title].
Future<ResultProbe<String>> _openSheet(
  WidgetTester tester,
  String title,
  String sheet,
) async {
  final probe = ResultProbe(
    navigatorTitled(tester, title).push(
      MaterialPageRoute<String>(
        builder: (context) => Scaffold(appBar: AppBar(title: Text(sheet))),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return probe;
}

Future<void> _systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('predictive back with a pageless route in a middle column '
      'closes only it', (tester) async {
    final router = await pumpColumns(
      tester,
      columnBackRoutes([]),
      const PlayerRoute(1, 'ann'),
    );
    final sheet = await _openSheet(tester, 'Room 1', 'Sheet');

    await tester.predictiveBack();

    expect(sheet.completions, [null]);
    expect(router.state.toString(), _all);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('the back button closes a pageless route in a middle column '
      'before the deepest column', (tester) async {
    final router = await pumpColumns(
      tester,
      columnBackRoutes([]),
      const PlayerRoute(1, 'ann'),
    );
    final sheet = await _openSheet(tester, 'Room 1', 'Sheet');

    await _systemBack(tester);
    expect(sheet.completions, [null]);
    expect(router.state.toString(), _all);

    await _systemBack(tester);
    expect(router.state.toString(), '[RoomsRoute() > RoomRoute(RoomId(1))]');
  });

  testWidgets('pageless routes in two columns close from the right', (
    tester,
  ) async {
    await pumpColumns(
      tester,
      columnBackRoutes([]),
      const PlayerRoute(1, 'ann'),
    );
    final middle = await _openSheet(tester, 'Room 1', 'Middle sheet');
    final first = await _openSheet(tester, 'Rooms', 'First sheet');

    await _systemBack(tester);
    expect(middle.completions, [null]);
    expect(first.completions, isEmpty);

    await _systemBack(tester);
    expect(first.completions, [null]);
  });
}
