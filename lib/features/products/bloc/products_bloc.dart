import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api_service.dart';
import '../../../core/product.dart';
import '../../../core/product_repository.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc(this.repository) : super(const ProductsState()) {
    on<ProductsSearchInputChanged>((event, emit) {
      _searchTimer?.cancel();
      _searchTimer = Timer(
        const Duration(milliseconds: 400),
        () => add(ProductsQueryChanged(event.value)),
      );
    });
    on<ProductsStarted>((event, emit) async {
      final cached = await repository.cachedProducts();
      emit(state.copyWith(items: cached, loading: cached.isEmpty));
      await _loadFirst(emit, state.query);
    });
    on<ProductsQueryChanged>((event, emit) async {
      final query = event.query.trim();
      if (query == state.query) return;
      _generation++;
      final generation = _generation;
      emit(
        state.copyWith(
          query: query,
          items: [],
          total: 0,
          nextOffset: 0,
          loading: true,
          loadingMore: false,
          error: '',
        ),
      );
      await _fetch(emit, query, 0, generation);
    });
    on<ProductsRefreshed>((event, emit) async {
      _generation++;
      final generation = _generation;
      emit(state.copyWith(loading: true, error: ''));
      await _fetch(emit, state.query, 0, generation);
    });
    on<ProductsNextPageRequested>((event, emit) async {
      if (state.loading ||
          state.loadingMore ||
          state.items.length >= state.total) {
        return;
      }
      final generation = _generation;
      final offset = state.nextOffset;
      emit(state.copyWith(loadingMore: true));
      await _fetch(emit, state.query, offset, generation);
    });
    on<ProductsRetryRequested>((event, emit) async {
      _generation++;
      await _loadFirst(emit, state.query);
    });
  }

  final ProductRepository repository;
  int _generation = 0;
  Timer? _searchTimer;

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }

  Future<void> _loadFirst(Emitter<ProductsState> emit, String query) async {
    final generation = _generation;
    emit(state.copyWith(loading: true, error: ''));
    await _fetch(emit, query, 0, generation);
  }

  Future<void> _fetch(
    Emitter<ProductsState> emit,
    String query,
    int skip,
    int generation,
  ) async {
    try {
      final page = await repository.page(skip, query);
      if (generation != _generation) return;
      final items = skip == 0
          ? page.products
          : [...state.items, ...page.products];
      emit(
        state.copyWith(
          items: items,
          total: page.total,
          nextOffset: skip + page.products.length,
          loading: false,
          loadingMore: false,
          offline: false,
          error: '',
        ),
      );
    } catch (error) {
      if (generation != _generation) return;
      if (isConnectionFailure(error)) {
        final cached = await repository.cachedProducts();
        if (generation != _generation) return;
        final filtered = query.isEmpty
            ? cached
            : cached
                  .where(
                    (p) =>
                        p.title.toLowerCase().contains(query.toLowerCase()) ||
                        p.description.toLowerCase().contains(
                          query.toLowerCase(),
                        ),
                  )
                  .toList();
        emit(
          state.copyWith(
            items: skip == 0 ? filtered : state.items,
            offline: true,
            loading: false,
            loadingMore: false,
            error: '',
            total: filtered.length,
            nextOffset: filtered.length,
          ),
        );
      } else {
        emit(
          state.copyWith(
            loading: false,
            loadingMore: false,
            error: 'loadError',
          ),
        );
      }
    }
  }
}
