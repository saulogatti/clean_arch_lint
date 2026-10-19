/// ✅ Domain entity: the business object, with no knowledge of JSON, APIs,
/// databases or Flutter.
///
/// Suffix `Entity` → lives in `domain`.
class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
  });

  final String id;
  final String name;
  final double price;
}
