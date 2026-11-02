import 'api_service.dart';
import 'local_store.dart';
import 'product.dart';

class ProductRepository {
  ProductRepository(this.api, this.store);
  final ApiService api;
  final LocalStore store;

  Future<List<Product>> cachedProducts() => store.readProducts();

  Future<ProductPage> page(int skip, String query) async {
    final result = await api.products(skip, query);
    if (query.isEmpty) {
      final existing = skip == 0 ? <Product>[] : await store.readProducts();
      final byId = {for (final item in existing) item.id: item};
      for (final item in result.products) {
        byId[item.id] = item;
      }
      await store.saveProducts(byId.values.toList());
    }
    return result;
  }

  Future<Product?> cachedDetail(int id) async {
    final details = await store.readDetails();
    if (details.containsKey(id)) return details[id];
    for (final product in await store.readProducts()) {
      if (product.id == id) return product;
    }
    for (final product in await store.readFavourites()) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<Product> detail(int id) async {
    final product = await api.product(id);
    await store.saveDetail(product);
    return product;
  }
}
