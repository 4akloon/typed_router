// The Cupertino page factory recipe, verbatim from the core's README;
// readme_recipes_test.dart keeps the two the same.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';

final class CupertinoPageFactory implements PageFactory {
  const CupertinoPageFactory({this.fullscreenDialog = false});

  final bool fullscreenDialog;

  @override
  Page<Object?> createPage(PageRequest request) => CupertinoPage<Object?>(
    key: request.key,
    name: request.name,
    fullscreenDialog: fullscreenDialog,
    child: request.child,
  );
}
