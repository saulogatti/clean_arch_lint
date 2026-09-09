/// ❌ BAD EXAMPLE: Core importing Data.
///
/// Current rule does not have a dedicated "core must not import data" check
/// (that was `core_no_data_or_presentation`). Core is only blocked from
/// importing `screens` / `presentation`.
library;

import 'package:clean_archt_lint_example/data/models/product_model.dart'; // ❌ ERROR: Core cannot import Data

class BadGetProduct {
  ProductModel call(String id) {
    // Core should not know data implementations
    return const ProductModel(id: '1', name: 'Product', price: 99.99);
  }
}
