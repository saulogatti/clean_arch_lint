import 'package:clean_archt_lint_example/domain/entities/product_entity.dart';

/// ✅ Domain contract: declares what the domain needs. The `data` layer
/// implements it ([ProductRepositoryContract] → `ProductRepositoryImpl`), so
/// the dependency points inward.
///
/// Suffix `RepositoryContract` → lives in `domain`.
abstract interface class ProductRepositoryContract {
  Future<ProductEntity?> findById(String id);
}
