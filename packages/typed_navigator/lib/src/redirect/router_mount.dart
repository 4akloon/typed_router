import 'package:flutter/widgets.dart';

/// Whether the router is shown, and the context its redirects get then.
///
/// The router's `RedirectScope` attaches its context when it is built and
/// detaches it when it leaves the tree. Without a context, navigation runs
/// no redirects; they run when the router is shown again.
final class RouterMount {
  BuildContext? _context;

  /// The context of the widget at the root of the router's delegate, or
  /// `null` while the router is not shown.
  BuildContext? get context => _context;

  /// The router is shown under [context].
  void attach(BuildContext context) => _context = context;

  /// The widget under [context] left the tree. A newer context, from the
  /// router shown in another place, stays.
  void detach(BuildContext context) {
    if (identical(_context, context)) _context = null;
  }
}
