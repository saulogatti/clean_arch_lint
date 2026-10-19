/// ❌ BAD EXAMPLE: Screens importing Data.
///
/// Violation of `no_data_dependencies`: screens get their view models
/// ready-made from the composition root (`lib/main.dart`).
library;

import 'package:clean_archt_lint_example/data/datasources/product_remote_data_source.dart'; // ❌ no_data_dependencies

Type badScreensDependency() => ProductRemoteDataSource;
