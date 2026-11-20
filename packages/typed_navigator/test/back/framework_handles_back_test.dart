// Android 14+ learns whether the app handles back, so the system can animate
// "back to home" on the first page.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator_test/typed_navigator_test.dart';

import '../support/back_fixtures.dart';
import '../support/operation_fixtures.dart';

void main() {
  testWidgets(
    'the platform learns whether the app handles back',
    (tester) async {
      // WidgetsApp tells the platform nothing before the app is resumed.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final platform = PlatformNavigationLog(tester);
      final router = await pumpMaterialRooms(tester);
      await tester.pumpAndSettle();
      expect(platform.frameworkHandlesBack.last, isFalse);

      await pushAndSettle(tester, router, room7);
      expect(platform.frameworkHandlesBack.last, isTrue);

      router.pop();
      await tester.pumpAndSettle();
      expect(platform.frameworkHandlesBack.last, isFalse);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
