import 'package:clean_archt_lint_example/core/utils/price_formatter_util.dart';
import 'package:clean_archt_lint_example/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';

/// ✅ Page: widget that renders a domain entity, with help from `core`.
///
/// Suffix `Page` → lives in `presentation`.
class ProductPage extends StatelessWidget {
  const ProductPage({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(product.name),
        Text(const PriceFormatterUtil().format(product.price)),
      ],
    );
  }
}
