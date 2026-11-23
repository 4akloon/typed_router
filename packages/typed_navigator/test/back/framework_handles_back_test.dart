// Android 14+ learns whether the app handles back, so the system can animate
// "back to home" on the first page.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_test/typed_navigator_test.dart';

import '../support/back_fixtures.dart';
import '../support/material_page_factory.dart';
import '../support/operation_fixtures.dart';
import '../support/tabs_fixtures.dart';

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

  testWidgets(
    'tabs tell the platform only what the visible branch can pop',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final platform = PlatformNavigationLog(tester);
      final router = TypedRouter(
        routes: tabsRoutes(ScreenLog()),
        initialRoute: rooms,
        pageFactory: const MaterialPageFactory(),
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(platform.frameworkHandlesBack.last, isFalse);

      await settled(tester, () => router.go(friends));
      expect(platform.frameworkHandlesBack.last, isFalse);

      await settled(tester, () => router.push(ann).ignore());
      expect(platform.frameworkHandlesBack.last, isTrue);

      // The rooms branch keeps a room open, hidden: it does not count.
      await settled(tester, router.pop<Object?>);
      await settled(tester, () => router.go(room7));
      await settled(tester, () => shellOf(tester).goBranch<FriendsBranch>());
      expect(find.text('Friends'), findsOneWidget);
      expect(platform.frameworkHandlesBack.last, isFalse);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
