import 'package:clean_arch_lint_example/features/cart/domain/entities/cart_item_entity.dart';

/// ✅ Data model of the `cart` feature: the cart item in the API format.
///
/// Suffix `Model` → lives in `data`.
class CartItemModel {
  const CartItemModel({required this.productId, required this.qty});

  final String productId;
  final int qty;

  CartItemEntity toEntity() => CartItemEntity(productId: productId, quantity: qty);
}
