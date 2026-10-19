/// ❌ BAD EXAMPLE: Data importing Presentation.
///
/// Violation of `no_screens_dependencies`: data must not know about UI.
library;

import 'package:clean_arch_lint_example/presentation/view_models/product_view_model.dart'; // ❌ no_screens_dependencies

Type badDataDependency() => ProductViewModel;
