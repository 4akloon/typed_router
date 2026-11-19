// Platform back gestures for widget tests: Android predictive back through
// the `flutter/backgesture` channel, the iOS edge swipe as a drag.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A theme whose Android pages take predictive back gestures.
final ThemeData predictiveBackTheme = ThemeData(
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {TargetPlatform.android: PredictiveBackPageTransitionsBuilder()},
  ),
);

/// Starts, drags and commits an Android predictive back gesture.
Future<void> predictiveBack(WidgetTester tester) async {
  await _backGesture(tester, 'startBackGesture', {
    'touchOffset': <double>[5, 300],
    'progress': 0.0,
    'swipeEdge': 0,
  });
  await tester.pump();
  await _backGesture(tester, 'updateBackGestureProgress', {
    'x': 100.0,
    'y': 300.0,
    'progress': 0.35,
    'swipeEdge': 0,
  });
  await tester.pump();
  await _backGesture(tester, 'commitBackGesture');
  await tester.pumpAndSettle();
}

/// Swipes from the left edge across the screen, as on iOS.
Future<void> iosEdgeSwipe(WidgetTester tester) async {
  await tester.dragFrom(const Offset(5, 300), const Offset(500, 0));
  await tester.pumpAndSettle();
}

Future<void> _backGesture(
  WidgetTester tester,
  String method, [
  Map<String, Object?>? arguments,
]) => tester.binding.defaultBinaryMessenger.handlePlatformMessage(
  'flutter/backgesture',
  const StandardMethodCodec().encodeMethodCall(MethodCall(method, arguments)),
  (_) {},
);
