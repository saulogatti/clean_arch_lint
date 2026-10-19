/// 🔕 IGNORED EXAMPLE: Presentation importing Data, suppressed on one line.
///
/// Same violation as `bad_example_data.dart`, but the `// ignore:` comment
/// right above the import silences `no_data_dependencies` for that directive
/// only. Use it for documented exceptions, never to hide a real dependency.
library;

// ignore: clean_arch_lint/no_data_dependencies
import 'package:clean_arch_lint_example/data/models/product_model.dart';

Type ignoredPresentationDependency() => ProductModel;
