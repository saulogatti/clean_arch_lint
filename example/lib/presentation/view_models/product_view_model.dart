import 'package:clean_arch_lint_example/domain/entities/product_entity.dart';
import 'package:clean_arch_lint_example/domain/usecases/get_product_use_case.dart';
import 'package:flutter/foundation.dart';

/// ✅ View model: UI state built from domain use cases only. It never sees
/// `ProductModel` or `ProductRepositoryImpl`.
///
/// Suffix `ViewModel` → lives in `presentation`.
class ProductViewModel extends ChangeNotifier {
  ProductViewModel(this._getProduct);

  final GetProductUseCase _getProduct;

  ProductEntity? product;
  bool isLoading = false;

  Future<void> load(String id) async {
    isLoading = true;
    notifyListeners();
    product = await _getProduct(id);
    isLoading = false;
    notifyListeners();
  }
}
