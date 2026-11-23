import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records what the app tells the platform about navigation, for the rest
/// of the test.
///
/// Creating it intercepts `SystemChannels.platform` on the test's
/// messenger; the interception ends with the test. Other platform calls on
/// that channel (clipboard, haptics) are answered with `null` while it
/// records. An identity object, not a value: it grows as the app talks.
///
/// ```dart
/// final platform = PlatformNavigationLog(tester);
/// await tester.pumpWidget(MaterialApp.router(routerConfig: router));
///
/// await tester.systemBack();
///
/// expect(platform.closedApp, isTrue);
/// ```
///
/// Experimental until 1.0: it may change without a major version.
class PlatformNavigationLog {
  /// Starts recording; stops when the test ends.
  PlatformNavigationLog(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger
      ..setMockMethodCallHandler(SystemChannels.platform, _record);
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
  }

  final List<MethodCall> _calls = [];

  /// Whether the app asked the platform to close it (`SystemNavigator.pop`).
  bool get closedApp =>
      _calls.any((call) => call.method == 'SystemNavigator.pop');

  /// Every `setFrameworkHandlesBack` value, in order.
  ///
  /// Android only, and only once the app is resumed: `WidgetsApp` tells the
  /// platform nothing before that. A test sets it with
  /// `tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed)`.
  List<bool> get frameworkHandlesBack => List.unmodifiable([
    for (final call in _calls)
      if (call case MethodCall(
        method: 'SystemNavigator.setFrameworkHandlesBack',
        arguments: final bool handlesBack,
      ))
        handlesBack,
  ]);

  Future<Object?> _record(MethodCall call) async {
    _calls.add(call);
    return null;
  }

  @override
  String toString() =>
      'PlatformNavigationLog(closedApp: $closedApp, '
      'frameworkHandlesBack: $frameworkHandlesBack)';
}
