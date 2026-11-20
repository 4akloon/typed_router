// The Material page factory recipe, verbatim from the core's README;
// readme_recipes_test.dart keeps the two the same.

import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';

final class MaterialPageFactory implements PageFactory {
  const MaterialPageFactory({this.fullscreenDialog = false});

  final bool fullscreenDialog;

  @override
  Page<Object?> createPage(PageRequest request) => MaterialPage<Object?>(
    key: request.key,
    name: request.name,
    fullscreenDialog: fullscreenDialog,
    child: request.child,
  );
}
