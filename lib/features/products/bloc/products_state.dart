part of 'products_bloc.dart';

class ProductsState {
  const ProductsState({
    this.items = const [],
    this.query = '',
    this.total = 0,
    this.nextOffset = 0,
    this.loading = false,
    this.loadingMore = false,
    this.offline = false,
    this.error = '',
  });
  final List<Product> items;
  final String query;
  final int total;
  final int nextOffset;
  final bool loading;
  final bool loadingMore;
  final bool offline;
  final String error;

  ProductsState copyWith({
    List<Product>? items,
    String? query,
    int? total,
    int? nextOffset,
    bool? loading,
    bool? loadingMore,
    bool? offline,
    String? error,
  }) => ProductsState(
    items: items ?? this.items,
    query: query ?? this.query,
    total: total ?? this.total,
    nextOffset: nextOffset ?? this.nextOffset,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    offline: offline ?? this.offline,
    error: error ?? this.error,
  );
}
