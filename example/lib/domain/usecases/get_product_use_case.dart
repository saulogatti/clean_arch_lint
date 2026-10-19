import 'package:clean_archt_lint_example/domain/entities/product_entity.dart';
import 'package:clean_archt_lint_example/domain/repositories/product_repository_contract.dart';

/// ✅ Domain use case: application rule that depends only on domain types.
///
/// Suffix `UseCase` → lives in `domain`.
class GetProductUseCase {
  const GetProductUseCase(this._repository);

  final ProductRepositoryContract _repository;

  Future<ProductEntity?> call(String id) => _repository.findById(id);
}
