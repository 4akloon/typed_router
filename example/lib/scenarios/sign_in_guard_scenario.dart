import 'package:flutter/material.dart';
import 'package:typed_navigator/material.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/scenarios/sign_in_routes.dart';
import 'package:typed_navigator_example/scenarios/sign_in_session.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const signInGuardScenario = Scenario(
  title: 'Sign-in guard (redirects)',
  summary: 'A router redirect, a node redirect and refreshListenable.',
  instructions: [
    'Open Account while signed out: the router\'s redirect sends you to '
        'SignInRoute(AccountRoute()).',
    'Sign in: the session notifies refreshListenable, the redirects '
        're-check, and you land on Account.',
    'Sign out on Account: the re-check finds a route that needs sign-in '
        '(AuthArea) and sends you to sign in again.',
    'Signed in, open Admin without the admin role: the node\'s own '
        'redirect sends you to NotAllowedRoute. Grant the role on Account, '
        'go back and open Admin again: it opens.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => _SignInGuardDemo(frame);

/// Owns the session, which outlives the router's every navigation.
final class _SignInGuardDemo extends StatefulWidget {
  const _SignInGuardDemo(this.frame);

  final ScenarioFrame frame;

  @override
  State<_SignInGuardDemo> createState() => _SignInGuardDemoState();
}

final class _SignInGuardDemoState extends State<_SignInGuardDemo> {
  final SignInSession _session = SignInSession();

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  TypedRouter _createRouter() => TypedRouter(
    routes: signInRoutes(_session),
    initialRoute: const HomeRoute(),
    pageFactory: const MaterialPageFactory(),
    refreshListenable: _session,
    redirect: (context, target) => switch (target.top) {
      _ when target.contains<AuthArea>() && !_session.isSignedIn => SignInRoute(
        returnTo: target.top,
      ),
      SignInRoute(:final returnTo) when _session.isSignedIn => returnTo,
      _ => null,
    },
  );

  @override
  Widget build(BuildContext context) =>
      RouterDemo(frame: widget.frame, createRouter: _createRouter);
}
