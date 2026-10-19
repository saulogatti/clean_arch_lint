/// ✅ Core utility: shared code with no business rule, usable by any layer.
///
/// Suffix `Util` → lives in `core`.
class PriceFormatterUtil {
  const PriceFormatterUtil();

  String format(double price) => '\$${price.toStringAsFixed(2)}';
}
