/// ❌ BAD EXAMPLE: Domain importing Data in /lib/src/domain/ structure
///
/// This file demonstrates a VIOLATION of the domain_only rule
/// when using the /lib/src/domain/ structure
library;

import 'package:clean_archt_lint_example/src/data/models/product_model.dart';
import 'package:clean_archt_lint_example/src/domain/entities/product.dart';

class BadExampleData {
  ProductModel getProduct(String id) {
    return ProductModel(id: id, name: 'Product', price: 99.99);
  }

  Product getProductEntity(String id) {
    return Product(id: id, name: 'Product', price: 99.99);
  }
}
