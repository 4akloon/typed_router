import 'package:flutter/widgets.dart';

/// Keeps the navigator of a branch alive in a container that disposes what it
/// scrolls away from (a `PageView`, a `TabBarView`), as go_router's
/// `_BranchNavigatorProxy` does.
final class BranchKeepAlive extends StatefulWidget {
  /// Creates the keep-alive around [child], a branch's navigator.
  const BranchKeepAlive({required this.child, super.key});

  /// The branch's navigator, or the empty box of a branch not visited.
  final Widget child;

  @override
  State<BranchKeepAlive> createState() => _BranchKeepAliveState();
}

final class _BranchKeepAliveState extends State<BranchKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
