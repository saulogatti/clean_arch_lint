/// ❌ BAD EXAMPLE: Core importing Presentation.
///
/// Violation of `no_screens_dependencies`: core is shared code and must not
/// know about UI.
library;

import 'package:clean_archt_lint_example/presentation/pages/product_page.dart'; // ❌ no_screens_dependencies

Type badCoreDependency() => ProductPage;
