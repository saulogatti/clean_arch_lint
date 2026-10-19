import 'package:clean_arch_lint_example/data/datasources/product_remote_data_source.dart';
import 'package:clean_arch_lint_example/data/models/product_model.dart';
import 'package:clean_arch_lint_example/domain/entities/product_entity.dart';
import 'package:clean_arch_lint_example/domain/repositories/product_repository_contract.dart';

/// ✅ Repository implementation: implements the domain contract and converts
/// [ProductModel] into [ProductEntity].
///
/// Suffix `RepositoryImpl` → lives in `data`.
class ProductRepositoryImpl implements ProductRepositoryContract {
  const ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<ProductEntity?> findById(String id) async {
    final json = await _remote.fetchProduct(id);
    return json == null ? null : ProductModel.fromJson(json).toEntity();
  }
}
