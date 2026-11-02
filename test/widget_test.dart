import 'package:flutter_test/flutter_test.dart';
import 'package:product_list_auth_app/core/product.dart';
import 'package:product_list_auth_app/features/scanner/scan_code_parser.dart';

void main() {
  test('product parsing tolerates absent optional fields', () {
    final product = Product.fromJson({
      'id': 3,
      'title': 'Test item',
      'price': 12,
      'rating': 4.5,
      'category': 'home',
      'description': 'Description',
    });
    expect(product.brand, isNull);
    expect(product.images, isEmpty);
    expect(product.thumbnail, isEmpty);
    expect(product.price, 12.0);
  });

  test('product code parser accepts only catalogue product links', () {
    expect(parseProductCode('catalogue://product/3'), 3);
    for (final code in [
      'https://product/3',
      'catalogue://other/3',
      'catalogue://product/0',
      'catalogue://product/-3',
      'catalogue://product/3/4',
      'catalogue://product/abc',
      'catalogue://product/3?x=1',
      '',
    ]) {
      expect(parseProductCode(code), isNull, reason: code);
    }
  });
}
