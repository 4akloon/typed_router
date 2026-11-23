// Platform back in widget tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:typed_router_test/typed_router_test.dart';

import 'support/rooms_app.dart';

final _android = TargetPlatformVariant.only(TargetPlatform.android);

void main() {
  testWidgets('systemBack removes the top page and settles the frame', (
    tester,
  ) async {
    final room = await pumpRoomOverRooms(tester);

    await tester.systemBack();

    expectRoomsOnly();
    expect(room.completions, [null]);
  }, variant: _android);

  testWidgets('predictiveBack removes the top page on Android', (
    tester,
  ) async {
    final room = await pumpRoomOverRooms(tester, theme: predictiveBackTheme);

    await tester.predictiveBack();

    expectRoomsOnly();
    expect(room.completions, [null]);
  }, variant: _android);

  testWidgets('iosEdgeSwipe removes the top page on iOS', (tester) async {
    final room = await pumpRoomOverRooms(tester);

    await tester.iosEdgeSwipe();

    expectRoomsOnly();
    expect(room.completions, [null]);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('the log sees the app closing only from the first page', (
    tester,
  ) async {
    final platform = PlatformNavigationLog(tester);
    await pumpRoomOverRooms(tester);

    await tester.systemBack();
    expect(platform.closedApp, isFalse);

    await tester.systemBack();
    expect(platform.closedApp, isTrue);
  }, variant: _android);

  testWidgets('the log records whether the app handles back', (tester) async {
    // WidgetsApp tells the platform nothing before the app is resumed.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final platform = PlatformNavigationLog(tester);
    final navigator = await pumpRooms(tester);
    await tester.pumpAndSettle();
    // The framework repeats a value on every navigation notification; the
    // log keeps what was sent, so each step checks the latest.
    expect(platform.frameworkHandlesBack.last, isFalse);

    await pushRoom(tester, navigator);
    expect(platform.frameworkHandlesBack.last, isTrue);

    await tester.systemBack();
    expect(platform.frameworkHandlesBack.last, isFalse);
  }, variant: _android);
}
