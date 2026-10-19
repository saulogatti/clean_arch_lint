/// ✅ Data source: talks to the outside world. Here it returns a fixed JSON
/// payload instead of calling a real API.
///
/// Suffix `DataSource` → lives in `data`.
class ProductRemoteDataSource {
  Future<Map<String, dynamic>?> fetchProduct(String id) async {
    if (id != '1') return null;
    return {
      'id': '1',
      'product_name': 'Mechanical keyboard',
      'price_cents': 19990,
    };
  }
}
