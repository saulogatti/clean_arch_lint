/// ❌ BAD EXAMPLE: Domain importing Data in /lib/src/domain/ structure
///
/// This file demonstrates a VIOLATION of the domain_only rule
/// when using the /lib/src/domain/ structure
library;

import 'package:clean_archt_lint_example/src/data/models/product_model.dart';

class BadExampleData {
  ProductModel getProduct(String id) {
    return ProductModel(id: id, name: 'Product', price: 99.99);
  }
}
