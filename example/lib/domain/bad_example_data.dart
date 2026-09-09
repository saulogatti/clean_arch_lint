/// ❌ BAD EXAMPLE: Domain importing Data.
///
/// Violation of `domain_only_depends_on_itself`.
library;

import 'package:clean_archt_lint_example/data/models/product_model.dart';
import 'package:clean_archt_lint_example/domain/entities/product.dart';

class BadExampleData {
  ProductModel getProduct(String id) {
    return ProductModel(id: id, name: 'Product', price: 99.99);
  }

  Product getProductEntity(String id) {
    return Product(id: id, name: 'Product', price: 99.99);
  }
}
