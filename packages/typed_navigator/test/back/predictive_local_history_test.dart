// A predictive back gesture over a level closes what a page inside opened first
// (a drawer, a bottom sheet: a local history entry), as over a plain page.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator_test/typed_navigator_test.dart';

import '../support/back_fixtures.dart';
import '../support/route_fixtures.dart';
import '../support/shell_fixtures.dart';

void main() {
  testWidgets('predictive back over a level closes a drawer inside first', (
    tester,
  ) async {
    final router = await pumpPushedOverAccount(
      tester,
      shellRoutes(FrameLog()),
      [
        users,
      ],
    );
    var isClosed = false;
    // What a drawer adds to the page's route when it opens.
    ModalRoute.of(tester.element(find.text('Users')))?.addLocalHistoryEntry(
      LocalHistoryEntry(onRemove: () => isClosed = true),
    );
    await tester.pumpAndSettle();

    await tester.predictiveBack();

    expect(isClosed, isTrue);
    expect(router.state.routes, const [AccountRoute(), users]);
    expect(find.text('Users'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
