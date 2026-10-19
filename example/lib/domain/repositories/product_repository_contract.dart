import 'dart:async';

import 'package:clean_archt_lint_example/domain/entities/product_entity.dart';

/// ✅ Domain contract: declares what the domain needs. The `data` layer
/// implements it ([ProductRepositoryContract] → `ProductRepositoryImpl`), so
/// the dependency points inward.
///
/// `dart:async` is one of the pure Dart libraries allowed in domain; the
/// [FutureOr] return type lets an implementation answer synchronously (e.g.
/// from a cache) or asynchronously.
///
/// Suffix `RepositoryContract` → lives in `domain`.
abstract interface class ProductRepositoryContract {
  FutureOr<ProductEntity?> findById(String id);
}
