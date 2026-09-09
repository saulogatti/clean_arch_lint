/// ❌ BAD EXAMPLE: Data importing Presentation.
///
/// Violation of `no_screens_dependencies` / `no_data_dependencies`.
library;

import 'package:clean_archt_lint_example/core/entities/product.dart';
import 'package:clean_archt_lint_example/presentation/pages/product_page.dart'; // ❌ ERROR: Data cannot import Presentation

class BadProductRepository {
  ProductPage getProductPage(String id) {
    // Data should not know the presentation layer
    final product = Product(id: id, name: 'Product', price: 99.99);
    return ProductPage(product: product);
  }
}
