/// ❌ BAD EXAMPLE: Presentation re-exporting Data.
///
/// Violation of `no_data_dependencies`: an `export` leaks `ProductModel` to
/// every file that imports this one, so exports are checked like imports.
library;

export '../data/models/product_model.dart' show ProductModel; // ❌ no_data_dependencies
