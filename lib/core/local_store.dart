import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'product.dart';

class LocalStore {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<List<Product>> readProducts() async =>
      _decode(await _prefs.getString('catalogue_products') ?? '[]');

  Future<void> saveProducts(List<Product> products) =>
      _prefs.setString('catalogue_products', _encode(products));

  Future<Map<int, Product>> readDetails() async {
    final products = _decode(
      await _prefs.getString('catalogue_details') ?? '[]',
    );
    return {for (final product in products) product.id: product};
  }

  Future<void> saveDetail(Product product) async {
    final details = await readDetails();
    details[product.id] = product;
    await _prefs.setString(
      'catalogue_details',
      _encode(details.values.toList()),
    );
  }

  Future<List<Product>> readFavourites() async =>
      _decode(await _prefs.getString('catalogue_favourites') ?? '[]');

  Future<void> saveFavourites(List<Product> products) =>
      _prefs.setString('catalogue_favourites', _encode(products));

  Future<String> readLanguage() async =>
      await _prefs.getString('catalogue_language') ?? 'en';

  Future<void> saveLanguage(String language) =>
      _prefs.setString('catalogue_language', language);

  Future<bool> readDarkMode() async =>
      await _prefs.getBool('catalogue_dark_mode') ?? false;

  Future<void> saveDarkMode(bool enabled) =>
      _prefs.setBool('catalogue_dark_mode', enabled);

  String _encode(List<Product> products) =>
      jsonEncode(products.map((p) => p.toJson()).toList());

  List<Product> _decode(String value) {
    try {
      return (jsonDecode(value) as List<dynamic>)
          .map(
            (item) => Product.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .where((product) => product.id > 0)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
