import 'package:clean_archt_lint_example/domain/entities/product_entity.dart';

/// ✅ Data model: the product in the API format. Field names and units follow
/// the API, and [toEntity] converts it before it leaves the `data` layer.
///
/// Suffix `Model` → lives in `data`.
class ProductModel {
  const ProductModel({
    required this.id,
    required this.productName,
    required this.priceCents,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      productName: json['product_name'] as String,
      priceCents: json['price_cents'] as int,
    );
  }

  final String id;
  final String productName;
  final int priceCents;

  Map<String, dynamic> toJson() {
    return {'id': id, 'product_name': productName, 'price_cents': priceCents};
  }

  ProductEntity toEntity() {
    return ProductEntity(id: id, name: productName, price: priceCents / 100);
  }
}
