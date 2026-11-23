/// What back does for a page whose node has `onExit`, once nothing on the page
/// refuses it: pop the page through the router, or, on the router's only page,
/// leave the app. Either asks `onExit` first.
abstract interface class PageBack {
  /// Whether the page is the router's only page, so back leaves the app.
  bool get isOnlyPage;

  /// Pops the page with [result] through the router, which asks `onExit`.
  void pop(Object? result);

  /// Asks `onExit` and closes the app on `true`, as go_router's `popRoute`.
  void leaveApp();
}
