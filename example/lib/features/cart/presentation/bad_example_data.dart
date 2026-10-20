/// ❌ BAD EXAMPLE: Presentation importing Data inside a feature.
///
/// Violation of `no_data_dependencies`: layers under
/// `lib/features/<feature>/` follow the same rules as `lib/<layer>/`.
library;

import '../data/models/cart_item_model.dart'; // ❌ no_data_dependencies

Type badCartPresentationDependency() => CartItemModel;
