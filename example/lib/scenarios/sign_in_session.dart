import 'package:flutter/foundation.dart';

/// Who is signed in, for the sign-in guard scenario; the router's
/// `refreshListenable`, so the redirects re-check the stack when it
/// changes.
final class SignInSession extends ChangeNotifier {
  bool _isSignedIn = false;
  bool _isAdmin = false;

  bool get isSignedIn => _isSignedIn;

  bool get isAdmin => _isAdmin;

  void signIn() {
    _isSignedIn = true;
    notifyListeners();
  }

  void signOut() {
    _isSignedIn = false;
    _isAdmin = false;
    notifyListeners();
  }

  void grantAdmin() {
    _isAdmin = true;
    notifyListeners();
  }

  @override
  String toString() =>
      'SignInSession(isSignedIn: $_isSignedIn, isAdmin: $_isAdmin)';
}
