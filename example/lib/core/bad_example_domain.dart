/// ❌ BAD EXAMPLE: Core importing Domain.
///
/// Violation of `core_independent`: core is shared code with no business rule
/// and must not know the project's entities.
library;

import 'package:clean_arch_lint_example/domain/entities/product_entity.dart'; // ❌ core_independent

Type badCoreDependency() => ProductEntity;
