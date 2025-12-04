import 'package:auth_demo/api/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient apiClient;
  AuthCubit(this.apiClient) : super(AuthInitial()) {
    _checkAuth();
  }

  String _mapErrorToMessage(Object error) {
    final e = error.toString();

    // Ошибки интернета
    if (e.contains('SocketException') ||
        e.contains('ClientException') ||
        e.contains('HandshakeException')) {
      return 'Нет соединения с интернетом';
    }

    // Ошибки сервера
    if (e.contains('500') || e.contains('502') || e.contains('503')) {
      return 'Сервер временно недоступен. Попробуйте позже';
    }

    // Ошибки логики (из ApiClient)
    if (e.contains('Неверный код')) {
      return 'Вы ввели неверный код';
    }

    if (e.contains('FormatException')) {
      return 'Код должен состоять только из цифр';
    }

    // Если ошибка неизвестная
    return 'Произошла ошибка. Попробуйте еще раз';
  }

  Future<void> _checkAuth() async {
    try {
      final hasToken = await apiClient.hasToken();
      if (hasToken) {
        final userId = await apiClient.getUserId();
        emit(AuthAuthenticated(userId: userId));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> sendCode(String email) async {
    emit(AuthLoading());
    try {
      await apiClient.sendCode(email);
      emit(AuthSendCode(email: email));
    } catch (e) {
      emit(AuthError(message: _mapErrorToMessage(e)));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> confirmCode(String email, String code) async {
    emit(AuthLoading());
    try {
      await apiClient.confirm_code(email, int.parse(code));
      final user_id = await apiClient.getUserId();
      emit(AuthAuthenticated(userId: user_id));
    } catch (e) {
      emit(AuthError(message: _mapErrorToMessage(e)));
      emit(AuthSendCode(email: email));
    }
  }

  Future<void> Logout() async {
    await apiClient.logout();
    emit(AuthUnauthenticated());
  }
}
