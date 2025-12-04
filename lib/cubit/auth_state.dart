part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthSendCode extends AuthState {
  final String email;
  AuthSendCode({required this.email});
}

class AuthAuthenticated extends AuthState {
  final String userId;
  AuthAuthenticated({required this.userId});
}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}
