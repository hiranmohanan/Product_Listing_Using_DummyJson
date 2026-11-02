import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_list_auth_app/core/product.dart';
import 'package:product_list_auth_app/core/product_repository.dart';
import 'package:product_list_auth_app/features/scanner/bloc/scanner_bloc.dart';

class FakeScanProducts implements ProductRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Product?> cachedDetail(int id) async => null;

  @override
  Future<Product> detail(int id) async {
    if (id == 9999) {
      throw DioException(
        requestOptions: RequestOptions(path: '/products/$id'),
        response: Response(
          requestOptions: RequestOptions(path: '/products/$id'),
          statusCode: 404,
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return Product(
      id: id,
      title: 'Product $id',
      price: 10,
      rating: 4,
      category: 'test',
      description: '',
      thumbnail: '',
      images: const [],
    );
  }
}

void main() {
  test('scanner opens existing catalogue products', () async {
    for (final id in [3, 15]) {
      final bloc = ScannerBloc(FakeScanProducts());
      bloc.add(ScannerCodeDetected('catalogue://product/$id'));
      expect(
        (await bloc.stream.firstWhere((s) => s.result != null)).result,
        id,
      );
      await bloc.close();
    }
  });

  test('scanner reports missing product without navigating', () async {
    final bloc = ScannerBloc(FakeScanProducts());
    bloc.add(ScannerCodeDetected('catalogue://product/9999'));
    final state = await bloc.stream.firstWhere(
      (s) => s.error == 'productNotFound',
    );
    expect(state.result, isNull);
    await bloc.close();
  });

  test('scanner rejects unrelated QR content', () async {
    final bloc = ScannerBloc(FakeScanProducts());
    bloc.add(ScannerCodeDetected('https://example.com'));
    final state = await bloc.stream.firstWhere((s) => s.error == 'invalidCode');
    expect(state.result, isNull);
    await bloc.close();
  });
}
