import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_list_auth_app/core/product.dart';
import 'package:product_list_auth_app/core/product_repository.dart';
import 'package:product_list_auth_app/features/products/bloc/products_bloc.dart';

class FakeProducts implements ProductRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  final offsets = <int>[];
  bool offline = false;
  final cached = List.generate(20, (index) => sample(index + 1));

  @override
  Future<List<Product>> cachedProducts() async => cached;

  @override
  Future<ProductPage> page(int skip, String query) async {
    offsets.add(skip);
    if (offline) {
      throw DioException(
        requestOptions: RequestOptions(path: '/products'),
        type: DioExceptionType.connectionError,
      );
    }
    return ProductPage(
      List.generate(20, (index) => sample(skip + index + 1)),
      45,
    );
  }
}

Product sample(int id) => Product(
  id: id,
  title: 'Item',
  price: 10,
  rating: 4,
  category: 'home',
  description: '',
  thumbnail: '',
  images: const [],
);

void main() {
  test('catalogue loads cached items and appends the next page', () async {
    final repository = FakeProducts();
    final bloc = ProductsBloc(repository)..add(ProductsStarted());
    await bloc.stream.firstWhere(
      (state) => state.items.length == 20 && !state.loading,
    );
    bloc.add(ProductsNextPageRequested());
    await bloc.stream.firstWhere(
      (state) => state.items.length == 40 && !state.loadingMore,
    );
    expect(repository.offsets, [0, 20]);
    await bloc.close();
  });

  test(
    'connection failure retains cached products and marks offline',
    () async {
      final repository = FakeProducts()..offline = true;
      final bloc = ProductsBloc(repository)..add(ProductsStarted());
      final state = await bloc.stream.firstWhere((state) => state.offline);
      expect(state.items.length, 20);
      expect(state.error, isEmpty);
      await bloc.close();
    },
  );
}
