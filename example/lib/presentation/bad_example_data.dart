/// ⚠️ BAD EXAMPLE: Presentation importing Data.
///
/// Violation of `no_data_dependencies`.
library;

import 'package:clean_archt_lint_example/core/app_exemple.dart';
import 'package:clean_archt_lint_example/data/models/product_model.dart'; // ⚠️ WARNING: Presentation should not import Data directly

class BadProductController {
  Future<ProductModel> loadProduct(String id) async {
    BadGetProduct();
    // Presentation should not know data implementations
    // Should use only core entities and use cases
    return const ProductModel(id: '1', name: 'Product', price: 99.99);
  }
}
