import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.repository) : super(const AuthState()) {
    repository.onSessionExpired = () => add(LogoutRequested());
    on<AuthStarted>((event, emit) async {
      try {
        final restored = await repository.restore();
        emit(
          state.copyWith(
            status: restored ? AuthStatus.authenticated : AuthStatus.signedOut,
          ),
        );
      } catch (_) {
        emit(state.copyWith(status: AuthStatus.signedOut));
      }
    });
    on<UsernameChanged>(
      (event, emit) => emit(state.copyWith(username: event.value, error: '')),
    );
    on<PasswordChanged>(
      (event, emit) => emit(state.copyWith(password: event.value, error: '')),
    );
    on<PasswordVisibilityToggled>(
      (event, emit) => emit(state.copyWith(obscure: !state.obscure)),
    );
    on<LoginSubmitted>((event, emit) async {
      if (state.username.trim().isEmpty || state.password.isEmpty) return;
      emit(state.copyWith(status: AuthStatus.submitting, error: ''));
      try {
        await repository.login(state.username.trim(), state.password);
        emit(state.copyWith(status: AuthStatus.authenticated, password: ''));
      } on DioException catch (error) {
        final invalid =
            error.response?.statusCode == 400 ||
            error.response?.statusCode == 401;
        emit(
          state.copyWith(
            status: AuthStatus.signedOut,
            error: invalid ? 'invalidCredentials' : 'connectionError',
          ),
        );
      } catch (_) {
        emit(
          state.copyWith(
            status: AuthStatus.signedOut,
            error: 'connectionError',
          ),
        );
      }
    });
    on<LogoutRequested>((event, emit) async {
      await repository.logout();
      emit(const AuthState(status: AuthStatus.signedOut));
    });
  }
  final AuthRepository repository;
}
