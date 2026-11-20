import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/scenarios/sign_in_session.dart';
import 'package:typed_navigator_example/support/demo_button.dart';
import 'package:typed_navigator_example/support/demo_page.dart';

/// Routes only a signed-in user may see: a marker the redirect asks about
/// with `state.contains<AuthArea>()`.
abstract interface class AuthArea {}

/// The route tree of the sign-in guard scenario.
List<TreeNode<NoParentRoute>> signInRoutes(SignInSession session) => [
  RouteNode<HomeRoute>(
    build: (context, home) => DemoPage(
      title: 'Home',
      text: 'Anyone can see this page.',
      actions: [
        DemoButton(
          'open Account',
          onPressed: () => TypedRouter.of(context).go(const AccountRoute()),
        ),
        DemoButton(
          'open Admin',
          onPressed: () => TypedRouter.of(context).go(const AdminRoute()),
        ),
      ],
    ),
    children: [
      RouteNode<AccountRoute>(
        build: (context, account) => DemoPage(
          title: 'Account',
          text: 'Signed in.',
          actions: [
            DemoButton('Sign out', onPressed: session.signOut),
            DemoButton('Grant the admin role', onPressed: session.grantAdmin),
          ],
        ),
      ).withParent((account) => const HomeRoute()),
      RouteNode<AdminRoute>(
        build: (context, admin) =>
            const DemoPage(title: 'Admin', text: 'Admins only.', actions: []),
        redirect: (context, admin, target) =>
            session.isAdmin ? null : const NotAllowedRoute(),
      ).withParent((admin) => const HomeRoute()),
      RouteNode<NotAllowedRoute>(
        build: (context, notAllowed) => const DemoPage(
          title: 'Not allowed',
          text: 'The Admin node redirected here: no admin role.',
          actions: [],
        ),
      ).withParent((notAllowed) => const HomeRoute()),
    ],
  ),
  RouteNode<SignInRoute>(
    build: (context, signIn) => DemoPage(
      title: 'Sign in',
      text: 'Then return to ${signIn.returnTo}.',
      actions: [DemoButton('Sign in', onPressed: session.signIn)],
    ),
  ),
];

final class HomeRoute extends TypedRoute<void> {
  const HomeRoute();

  @override
  List<Object?> get fields => const [];
}

final class AccountRoute extends TypedRoute<void> implements AuthArea {
  const AccountRoute();

  @override
  List<Object?> get fields => const [];
}

final class AdminRoute extends TypedRoute<void> implements AuthArea {
  const AdminRoute();

  @override
  List<Object?> get fields => const [];
}

final class NotAllowedRoute extends TypedRoute<void> {
  const NotAllowedRoute();

  @override
  List<Object?> get fields => const [];
}

final class SignInRoute extends TypedRoute<void> {
  const SignInRoute({required this.returnTo});

  /// Where to go once signed in.
  final TypedRoute<Object?> returnTo;

  @override
  List<Object?> get fields => [returnTo];
}
