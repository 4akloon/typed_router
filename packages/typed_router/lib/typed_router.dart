/// Statically typed, tree-based navigation for Flutter on Navigator 2.0.
///
/// Routes are Dart values ([TypedRoute]) identified by their type and
/// fields, placed in a tree declared top-down ([RouteNode], [ShellNode],
/// [StatefulShellNode]) and shown by a [TypedRouter]:
///
/// ```dart
/// final router = TypedRouter(
///   routes: [
///     RouteNode<RoomsRoute>(
///       build: (context, rooms) => const RoomsScreen(),
///       children: [
///         RouteNode<RoomRoute>(
///           build: (context, room) => RoomScreen(id: room.id),
///         ).withParent((room) => const RoomsRoute()),
///       ],
///     ),
///   ],
///   initialRoute: const RoomsRoute(),
///   pageFactory: const MaterialPageFactory(), // a recipe from the README
/// );
///
/// runApp(MaterialApp.router(routerConfig: router));
/// ```
///
/// The guides (getting started, navigation, redirects, shells and tabs,
/// recipes, migrating from go_router) are in the package's `doc/` folder.
///
/// {@category getting-started}
/// {@category recipes}
/// {@category migrating-from-go-router}
library;

export 'src/page/page_factory.dart' show PageFactory;
export 'src/page/page_request.dart' show PageRequest;
export 'src/redirect/redirect_chain_error.dart' show RedirectChainError;
export 'src/route/typed_route.dart' show TypedRoute;
export 'src/router/typed_router.dart' show TypedRouter;
export 'src/router/typed_router_scope.dart' show TypedRouterScope;
export 'src/state/typed_router_state.dart' show TypedRouterState;
export 'src/tabs/stateful_shell.dart' show StatefulShell;
export 'src/tree/navigator_slot.dart' show NavigatorSlot;
export 'src/tree/no_parent_route.dart' show NoParentRoute;
export 'src/tree/tree_node.dart'
    show BranchNode, RouteNode, ShellNode, StatefulShellNode, TreeNode;
