/// Core importing Data: allowed, no diagnostic.
///
/// Core is only blocked from importing `screens` / `presentation`
/// (`no_screens_dependencies`). Prefer depending on domain contracts anyway.
library;

import 'package:clean_archt_lint_example/data/models/product_model.dart'; // allowed

class BadGetProduct {
  ProductModel call(String id) {
    return const ProductModel(id: '1', name: 'Product', price: 99.99);
  }
}
