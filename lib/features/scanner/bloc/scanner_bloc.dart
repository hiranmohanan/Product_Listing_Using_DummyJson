import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/api_service.dart';
import '../../../core/product_repository.dart';
import '../scan_code_parser.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc(this.repository) : super(const ScannerState()) {
    on<ScannerStarted>((event, emit) => _request(emit));
    on<ScannerPermissionRetried>((event, emit) => _request(emit));
    on<ScannerManualOpened>(
      (event, emit) => emit(state.copyWith(manual: true, error: '')),
    );
    on<ScannerManualChanged>(
      (event, emit) => emit(state.copyWith(input: event.value, error: '')),
    );
    on<ScannerManualSubmitted>((event, emit) async {
      if (state.verifying) return;
      await _check(emit, state.input);
    });
    on<ScannerErrorDismissed>((event, emit) => emit(state.copyWith(error: '')));
    on<ScannerCodeDetected>((event, emit) async {
      if (state.result != null || state.manual || state.verifying) return;
      if (event.value == _lastInvalid) return;
      await _check(emit, event.value);
    });
    on<ScannerRetryLastCode>((event, emit) async {
      final code = _lastInvalid;
      if (code == null || state.verifying) return;
      _lastInvalid = null;
      await _check(emit, code);
    });
  }
  final ProductRepository repository;
  String? _lastInvalid;

  Future<void> _request(Emitter<ScannerState> emit) async {
    emit(state.copyWith(checking: true));
    final status = await Permission.camera.request();
    emit(state.copyWith(checking: false, allowed: status.isGranted));
  }

  Future<void> _check(Emitter<ScannerState> emit, String code) async {
    final id = parseProductCode(code);
    if (id == null) {
      _lastInvalid = code;
      emit(state.copyWith(error: 'invalidCode'));
      return;
    }
    emit(state.copyWith(verifying: true, error: ''));
    try {
      final cached = await repository.cachedDetail(id);
      if (cached == null) {
        await repository.detail(id);
      }
      emit(state.copyWith(result: id, verifying: false));
    } on DioException catch (error) {
      _lastInvalid = code;
      final message = error.response?.statusCode == 404
          ? 'productNotFound'
          : isConnectionFailure(error)
          ? 'offlineProduct'
          : 'loadError';
      emit(state.copyWith(verifying: false, error: message));
    } catch (_) {
      _lastInvalid = code;
      emit(state.copyWith(verifying: false, error: 'loadError'));
    }
  }
}
