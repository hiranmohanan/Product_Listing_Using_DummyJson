part of 'detail_bloc.dart';

class DetailState {
  const DetailState({
    this.product,
    this.loading = true,
    this.offline = false,
    this.error = '',
  });
  final Product? product;
  final bool loading;
  final bool offline;
  final String error;

  DetailState copyWith({
    Product? product,
    bool? loading,
    bool? offline,
    String? error,
  }) => DetailState(
    product: product ?? this.product,
    loading: loading ?? this.loading,
    offline: offline ?? this.offline,
    error: error ?? this.error,
  );
}
