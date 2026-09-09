// ignore: unused_import -- allowed by domain_only; Future is also exported by dart:core
import 'dart:async';

import 'package:clean_archt_lint_example/src/domain/entities/product.dart';

/// Contract to fetch a product.
///
/// Domain layer with /lib/src/domain/ structure - Dart SDK and domain only.
abstract class GetProduct {
  Future<Product?> call(String productId);
}
