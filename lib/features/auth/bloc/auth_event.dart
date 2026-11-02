part of 'auth_bloc.dart';

sealed class AuthEvent {}

class AuthStarted extends AuthEvent {}

class UsernameChanged extends AuthEvent {
  UsernameChanged(this.value);
  final String value;
}

class PasswordChanged extends AuthEvent {
  PasswordChanged(this.value);
  final String value;
}

class PasswordVisibilityToggled extends AuthEvent {}

class LoginSubmitted extends AuthEvent {}

class LogoutRequested extends AuthEvent {}
