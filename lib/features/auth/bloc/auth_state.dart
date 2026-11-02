part of 'auth_bloc.dart';

enum AuthStatus { checking, submitting, authenticated, signedOut }

class AuthState {
  const AuthState({
    this.status = AuthStatus.checking,
    this.username = '',
    this.password = '',
    this.obscure = true,
    this.error = '',
  });
  final AuthStatus status;
  final String username;
  final String password;
  final bool obscure;
  final String error;

  AuthState copyWith({
    AuthStatus? status,
    String? username,
    String? password,
    bool? obscure,
    String? error,
  }) => AuthState(
    status: status ?? this.status,
    username: username ?? this.username,
    password: password ?? this.password,
    obscure: obscure ?? this.obscure,
    error: error ?? this.error,
  );
}
