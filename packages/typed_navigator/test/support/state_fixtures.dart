// Builds navigation states for tests through the internal constructor.

import 'package:typed_navigator/src/state/navigation_entry.dart';
import 'package:typed_navigator/typed_navigator.dart';

/// A state whose active path holds [routes], bottom to top, each in a new
/// entry (a new page).
TypedRouterState stateOf(List<TypedRoute<Object?>> routes) =>
    TypedRouterState.fromEntries([
      for (final route in routes) NavigationEntry(route),
    ]);
