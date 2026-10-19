/// ❌ BAD EXAMPLE: Screens importing Data through a relative import.
///
/// Violation of `no_data_dependencies`: screens get their view models
/// ready-made from the composition root (`lib/main.dart`). The relative path
/// resolves to the same `package:` URI, so it is reported like any other
/// import.
library;

import '../data/datasources/product_remote_data_source.dart'; // ❌ no_data_dependencies

Type badScreensDependency() => ProductRemoteDataSource;
