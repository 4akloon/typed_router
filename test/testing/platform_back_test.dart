// Platform back in widget tests through `package:typed_navigator/testing.dart`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_navigator/testing.dart';

import '../support/back_fixtures.dart';
import '../support/operation_fixtures.dart';

void main() {
  testWidgets(
    'systemBack removes the top page and settles the frame',
    (tester) async {
      final router = await pumpMaterialRooms(tester);
      await pushAndSettle(tester, router, room7);

      await tester.systemBack();

      expect(router.state.routes, const [rooms]);
      expect(find.text('Rooms'), findsOneWidget);
      expect(find.text('Room 7', skipOffstage: false), findsNothing);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'predictiveBack removes the top page on Android',
    (tester) async {
      final router = await pumpMaterialRooms(
        tester,
        theme: predictiveBackTheme,
      );
      await pushAndSettle(tester, router, room7);

      await tester.predictiveBack();

      expect(router.state.routes, const [rooms]);
      expect(find.text('Rooms'), findsOneWidget);
      expect(find.text('Room 7', skipOffstage: false), findsNothing);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'iosEdgeSwipe removes the top page on iOS',
    (tester) async {
      final router = await pumpMaterialRooms(tester);
      await pushAndSettle(tester, router, room7);

      await tester.iosEdgeSwipe();

      expect(router.state.routes, const [rooms]);
      expect(find.text('Rooms'), findsOneWidget);
      expect(find.text('Room 7', skipOffstage: false), findsNothing);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'the log sees the app closing only from the first page',
    (tester) async {
      final platform = PlatformNavigationLog(tester);
      final router = await pumpMaterialRooms(tester);
      await pushAndSettle(tester, router, room7);

      await tester.systemBack();
      expect(platform.closedApp, isFalse);

      await tester.systemBack();
      expect(platform.closedApp, isTrue);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'the log records whether the app handles back',
    (tester) async {
      // WidgetsApp tells the platform nothing before the app is resumed.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final platform = PlatformNavigationLog(tester);
      final router = await pumpMaterialRooms(tester);
      await tester.pumpAndSettle();
      // The framework repeats a value on every navigation notification;
      // the log keeps what was sent, so each step checks the latest.
      expect(platform.frameworkHandlesBack.last, isFalse);

      await pushAndSettle(tester, router, room7);
      expect(platform.frameworkHandlesBack.last, isTrue);

      await tester.systemBack();
      expect(platform.frameworkHandlesBack.last, isFalse);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
