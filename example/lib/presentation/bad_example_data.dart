/// ❌ BAD EXAMPLE: Presentation importing Data.
///
/// Violation of `no_data_dependencies`: presentation should receive a
/// `GetProductUseCase`, not build `ProductRepositoryImpl` itself.
library;

import 'package:clean_arch_lint_example/data/repositories/product_repository_impl.dart'; // ❌ no_data_dependencies

Type badPresentationDependency() => ProductRepositoryImpl;
