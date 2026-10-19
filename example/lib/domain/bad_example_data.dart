/// ❌ BAD EXAMPLE: Domain importing Data.
///
/// Violation of `domain_only_depends_on_itself`: the domain must work with
/// `ProductEntity`, never with the API-shaped `ProductModel`.
library;

import 'package:clean_archt_lint_example/data/models/product_model.dart'; // ❌ domain_only_depends_on_itself

Type badDomainDependency() => ProductModel;
