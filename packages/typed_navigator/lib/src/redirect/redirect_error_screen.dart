import 'package:flutter/widgets.dart';

/// The error screen of a router without `errorBuilder`: says that the
/// navigation failed and shows the error.
///
/// Built on `widgets.dart` only, like go_router's `ErrorScreen`, without a
/// button home: home is the stack the redirects just failed on. Apps give
/// their own screen through `errorBuilder`.
final class RedirectErrorScreen extends StatelessWidget {
  /// Creates the screen for [error].
  const RedirectErrorScreen({required this.error, super.key});

  /// What the redirects threw.
  final Object error;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFFFFFFF),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Navigation failed\n\n$error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF000000), fontSize: 16),
        ),
      ),
    ),
  );
}
