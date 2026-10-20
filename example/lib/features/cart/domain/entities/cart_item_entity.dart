/// ✅ Entity of the `cart` feature, in a feature-first layout
/// (`lib/features/<feature>/<layer>/`).
///
/// Suffix `Entity` → lives in `domain`.
class CartItemEntity {
  const CartItemEntity({required this.productId, required this.quantity});

  final String productId;
  final int quantity;
}
