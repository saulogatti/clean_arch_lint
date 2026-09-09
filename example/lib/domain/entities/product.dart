/// Product entity in domain layer with /lib/src/domain/ structure
///
/// Example of valid file in /lib/src/domain/ structure
class Product {
  final String id;
  final String name;
  final double price;

  const Product({required this.id, required this.name, required this.price});
}
