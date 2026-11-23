// A plain Material app for the utilities' own tests: the utilities talk to
// the platform, not to the router, so a Navigator of pages is enough. Their
// use with the router is tested in typed_router's own back tests.

import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoPageTransitionsBuilder;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// A theme whose Android pages take predictive back gestures and whose iOS
/// pages keep the Cupertino back swipe. Made on each read: a theme takes
/// the test's platform when it is made.
ThemeData get predictiveBackTheme => ThemeData(
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
);

/// The result of the page pushed by [pumpRoomOverRooms], as it completes.
class PushedRoom {
  /// Records every completion of [result].
  PushedRoom(Future<Object?> result) {
    result.then(completions.add).ignore();
  }

  /// The values the push completed with; one at most.
  final List<Object?> completions = [];

  /// Whether the push has completed.
  bool get isCompleted => completions.isNotEmpty;
}

/// A Material app showing "Rooms"; returns its navigator.
Future<NavigatorState> pumpRooms(
  WidgetTester tester, {
  ThemeData? theme,
}) async {
  final navigatorKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      theme: theme,
      home: const Text('Rooms'),
    ),
  );
  return navigatorKey.currentState ?? (throw StateError('No navigator.'));
}

/// A Material app showing "Rooms" with "Room 7" pushed over it and
/// settled.
Future<PushedRoom> pumpRoomOverRooms(
  WidgetTester tester, {
  ThemeData? theme,
}) async => pushRoom(tester, await pumpRooms(tester, theme: theme));

/// Pushes "Room 7" on [navigator] and lets it settle.
Future<PushedRoom> pushRoom(
  WidgetTester tester,
  NavigatorState navigator,
) async {
  final room = PushedRoom(
    navigator.push<Object?>(
      MaterialPageRoute<Object?>(builder: (context) => const Text('Room 7')),
    ),
  );
  await tester.pumpAndSettle();
  return room;
}

/// Expects "Rooms" alone on screen: the pushed page is gone.
void expectRoomsOnly() {
  expect(find.text('Rooms'), findsOneWidget);
  expect(find.text('Room 7', skipOffstage: false), findsNothing);
}
