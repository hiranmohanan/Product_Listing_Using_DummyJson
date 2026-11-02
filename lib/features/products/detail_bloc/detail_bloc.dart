import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api_service.dart';
import '../../../core/product.dart';
import '../../../core/product_repository.dart';

part 'detail_event.dart';
part 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  DetailBloc(this.repository, this.id) : super(const DetailState()) {
    on<DetailStarted>((event, emit) => _load(emit));
    on<DetailRetried>((event, emit) => _load(emit));
  }
  final ProductRepository repository;
  final int id;

  Future<void> _load(Emitter<DetailState> emit) async {
    if (state.loading && state.product != null) return;
    emit(state.copyWith(loading: true, error: ''));
    final cached = await repository.cachedDetail(id);
    if (cached != null) {
      emit(state.copyWith(product: cached, loading: true));
    }
    try {
      final fresh = await repository.detail(id);
      emit(state.copyWith(product: fresh, loading: false, offline: false));
    } on DioException catch (error) {
      emit(
        state.copyWith(
          loading: false,
          offline: isConnectionFailure(error),
          error: error.response?.statusCode == 404
              ? 'productNotFound'
              : isConnectionFailure(error)
              ? 'offlineProduct'
              : 'loadError',
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'loadError'));
    }
  }
}
