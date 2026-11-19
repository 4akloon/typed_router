/// Statically typed, tree-based navigation for Flutter on Navigator 2.0.
///
/// Routes are Dart values identified by their type and fields, placed in a
/// tree declared top-down. URLs are an optional adapter at the platform
/// boundary.
library;

export 'src/page/page_factory.dart' show PageFactory;
export 'src/page/page_request.dart' show PageRequest;
export 'src/redirect/redirect_chain_error.dart' show RedirectChainError;
export 'src/route/typed_route.dart' show TypedRoute;
export 'src/router/typed_router.dart' show TypedRouter;
export 'src/state/navigation_state.dart' show NavigationState;
export 'src/tabs/stateful_shell.dart' show StatefulShell;
export 'src/tree/no_parent_route.dart' show NoParentRoute;
export 'src/tree/tree_node.dart'
    show BranchNode, RouteNode, ShellNode, StatefulShellNode, TreeNode;
